package main

import (
	"cmp"
	"context"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net"
	"net/http"
	"net/netip"
	"os"
	"slices"
	"strings"
	"sync"
	"text/tabwriter"
	"time"
)

type getIPErrorReason int

const (
	reasonNone getIPErrorReason = iota
	reasonDNS
	reasonTimeout
	reasonConnect
	reasonRead
	reasonNotAnIP
)

func (r getIPErrorReason) String() string {
	switch r {
	case reasonNone:
		return "-"
	case reasonDNS:
		return "dns"
	case reasonTimeout:
		return "timeout"
	case reasonConnect:
		return "connect"
	case reasonRead:
		return "read"
	case reasonNotAnIP:
		return "not-an-ip"
	default:
		return "Unknown"
	}
}

type getIPResult struct {
	name     string
	endpoint string
	status   string
	ip       netip.Addr
	reason   getIPErrorReason
}

func (r getIPResult) LogValue() slog.Value {
	return slog.GroupValue(
		slog.String("service", r.name),
		slog.String("url", r.endpoint),
		slog.String("status", r.status),
		slog.String("error_reason", r.reason.String()),
	)
}

func main() {
	start := time.Now()

	urls := map[string]string{
		"ident.me":   "http://ident.me",
		"wgetip.com": "http://wgetip.com",
		"ip.tyk.nu":  "http://ip.tyk.nu",
	}
	client := &http.Client{
		Timeout: 5 * time.Second,
	}
	var wg sync.WaitGroup
	w := tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', 0)
	fmt.Fprintln(w)
	fmt.Fprintln(w, "Service\tIP Address\tUrl\tStatus\tError Reason")

	c := make(chan getIPResult, len(urls))
	for name, endpoint := range urls {
		wg.Go(func() { fetchIP(endpoint, name, client, c) })
	}
	wg.Wait()
	close(c)

	results := make([]getIPResult, 0, len(urls))
	for r := range c {
		results = append(results, r)
	}

	slices.SortFunc(results, sortByIP)
	for _, r := range results {
		fmt.Fprintf(w, "%s\t%s\t%s\t%s\t%s\n", r.name, formatIP(r.ip), r.endpoint, r.status, r.reason)
	}
	fmt.Fprintln(w)
	w.Flush()

	fmt.Println("Done in", time.Since(start))
}

func fetchIP(endpoint string, name string, client *http.Client, c chan<- getIPResult) {
	result := getIPResult{
		name:     name,
		endpoint: endpoint,
		status:   "-",
		reason:   reasonNone,
	}
	defer func() { c <- result }()

	resp, err := client.Get(endpoint)
	if err != nil {
		result.reason = classifyGetIPErrorReason(err, reasonConnect)
		slog.Error("Запрос к серверу не прошёл", "error", err, "data", result)
		return
	}
	defer resp.Body.Close()

	result.status = resp.Status
	if resp.StatusCode < 200 || resp.StatusCode > 299 {
		return
	}

	maybeIP, err := io.ReadAll(io.LimitReader(resp.Body, 1024))
	if err != nil {
		result.reason = classifyGetIPErrorReason(err, reasonRead)
		slog.Error("Тело не прочитано", "error", err, "data", result)
		return
	}

	ip, err := netip.ParseAddr(strings.TrimSpace(string(maybeIP)))
	if err != nil {
		result.reason = reasonNotAnIP
		slog.Error("Не получилось распарсить Ip-адрес", "data", result)
		return
	}

	result.ip = ip
}

func sortByIP(r1, r2 getIPResult) int {
	if n := r1.ip.Compare(r2.ip); n != 0 {
		return n
	}
	return cmp.Compare(r1.name, r2.name)
}

func formatIP(ip netip.Addr) string {
	if !ip.IsValid() {
		return "-"
	}
	return ip.String()
}

func classifyGetIPErrorReason(err error, fallback getIPErrorReason) getIPErrorReason {
	var dnsErr *net.DNSError
	var netErr net.Error
	switch {
	case err == nil:
		return reasonNone
	case errors.As(err, &dnsErr):
		return reasonDNS
	case errors.Is(err, context.DeadlineExceeded) || errors.Is(err, os.ErrDeadlineExceeded):
		return reasonTimeout
	case errors.As(err, &netErr) && netErr.Timeout():
		return reasonTimeout
	default:
		return fallback
	}
}
