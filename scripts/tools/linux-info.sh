#!/usr/bin/env bash

set -euo pipefail

# --- RAM ---
ram_total=$(free -h | awk '/^Mem/{print $2}')
ram_used=$(free -h | awk '/^Mem/{print $3}')
ram_avail=$(free -h | awk '/^Mem/{print $7}')

# --- VRAM (AMD/Intel/NVIDIA) ---
vram_total="unknown"
vram_used="unknown"

# 1. Пытаемся найти через sysfs для amdgpu/nouveau/any DRM device
for card in /sys/class/drm/card*/device; do
  if [ -r "$card/mem_info_vram_total" ]; then
    vram_total_bytes=$(cat "$card/mem_info_vram_total" 2>/dev/null || echo "0")
    if [ "$vram_total_bytes" != "0" ] && [ "$vram_total_bytes" -gt 0 ] 2>/dev/null; then
      vram_total=$(echo "$vram_total_bytes" | awk '{printf "%.1f GiB", $1/1024/1024/1024}')
      if [ -r "$card/mem_info_vram_used" ]; then
        vram_used_bytes=$(cat "$card/mem_info_vram_used" 2>/dev/null || echo "0")
        vram_used=$(echo "$vram_used_bytes" | awk '{printf "%.1f GiB", $1/1024/1024/1024}')
      fi
      break
    fi
  fi
done

# 2. Fallback для NVIDIA (nvidia-smi)
if [ "$vram_total" = "unknown" ] && command -v nvidia-smi >/dev/null 2>&1; then
  vram_total_mb=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -n1 | awk '{$1=$1;print}')
  vram_used_mb=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null | head -n1 | awk '{$1=$1;print}')
  if [ -n "$vram_total_mb" ] && [ "$vram_total_mb" != "[Not Supported]" ] 2>/dev/null; then
    vram_total=$(echo "$vram_total_mb" | awk '{printf "%.1f GiB", $1/1024}')
    vram_used=$(echo "$vram_used_mb" | awk '{printf "%.1f GiB", $1/1024}')
  fi
fi

# 3. Fallback через glxinfo (работает только под X11/Wayland)
if [ "$vram_total" = "unknown" ] && command -v glxinfo >/dev/null 2>&1; then
  glx_vram=$(glxinfo -B 2>/dev/null | grep -oP 'Video memory:\s*\K[0-9]+' | head -n1)
  if [ -n "$glx_vram" ]; then
    vram_total="${glx_vram} MB"
  fi
fi

# --- Sound Server (PipeWire / PulseAudio) ---
sound_server="unknown"

if [ -S "${XDG_RUNTIME_DIR:-/tmp}/pipewire-0" ] 2>/dev/null || pgrep -x pipewire >/dev/null 2>&1; then
  if command -v pipewire >/dev/null 2>&1; then
    sound_server="PipeWire ($(pipewire --version | grep -oP '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1))"
  else
    sound_server="PipeWire"
  fi
elif [ -S "${XDG_RUNTIME_DIR:-/tmp}/pulse/native" ] 2>/dev/null || pgrep -x pulseaudio >/dev/null 2>&1; then
  if command -v pulseaudio >/dev/null 2>&1; then
    sound_server="PulseAudio ($(pulseaudio --version | grep -oP '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1))"
  else
    sound_server="PulseAudio"
  fi
fi

# 4. Fallback через lspci (парсим prefetchable BAR — приблизительно!)
if [ "$vram_total" = "unknown" ]; then
  amd_pci=$(lspci -nnk | awk '/VGA compatible controller.*AMD\/ATI|Display controller.*AMD\/ATI/{print $1; exit}')
  if [ -n "$amd_pci" ]; then
    bar_size=$(lspci -v -s "$amd_pci" 2>/dev/null | awk '/Memory at.*64-bit, prefetchable/{print $5; exit}')
    if [ -n "$bar_size" ]; then
      vram_total="~${bar_size} (BAR size, приблизительно)"
    fi
  fi
fi

info=$(
  echo "- **OS**: $(source /etc/os-release && echo "$NAME $VERSION_ID")"
  echo "- **Kernel**: $(uname -sr)"
  echo "- **Arch**: $(uname -m)"
  echo "- **CPU**: $(lscpu | grep 'Model name' | sed 's/Model name:[[:space:]]*//' | head -1)"
  echo "- **RAM Total**: ${ram_total}"
  echo "- **RAM Used**: ${ram_used}"
  echo "- **RAM Available**: ${ram_avail}"
  echo "- **VRAM Total**: ${vram_total}"
  echo "- **VRAM Used**: ${vram_used}"
  echo "- **GPU**:"
  lspci -nnk | awk '
    /VGA compatible controller|3D controller|Display controller/ {
      gsub(/^/, "  - "); print;
      getline;
      if (/Subsystem/) getline;
      if (/Kernel driver/) { gsub(/^/, "    "); print }
    }
  '
  if command -v glxinfo >/dev/null 2>&1; then
    echo "  - **Active renderer**: $(glxinfo -B 2>/dev/null | grep 'OpenGL renderer string' | cut -d: -f2 | xargs || echo 'unknown')"
  fi
  echo "- **Sound Server**: ${sound_server}"
  echo "- **Display Server**: ${XDG_SESSION_TYPE:-unknown}"
  echo "- **Session**: ${DISPLAY:-}${WAYLAND_DISPLAY:-}"
  echo "- **DE/WM**: ${XDG_CURRENT_DESKTOP:-unknown} / ${DESKTOP_SESSION:-unknown}"
  echo "- **Shell**: ${SHELL:-unknown}"
  echo "- **Terminal**: ${TERM_PROGRAM:-${TERMINAL:-unknown}}"
)

if [ -n "${DISPLAY:-}" ] && command -v xclip >/dev/null 2>&1; then
  echo "$info" | xclip -sel clip
elif [ -n "${WAYLAND_DISPLAY:-}" ] && command -v wl-copy >/dev/null 2>&1; then
  echo "$info" | wl-copy
else
  echo "$info"
  echo -e "\n⚠ Не скопировано (нет xclip/wl-copy)"
  exit 0
fi

echo "✓ Скопировано в буфер обмена"
echo "$info"