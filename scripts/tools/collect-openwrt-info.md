# collect-openwrt-info

Bash-скрипт для сбора информации с роутеров OpenWrt по SSH.

Скрипт формирует компактный отчёт, который можно использовать:

- для диагностики неисправностей;
- как контекст для локальных LLM.

Приоритет — получение наиболее полезных диагностических данных при минимальном размере отчёта.

## Требования

- Подключение к роутеру по SSH (хост из `~/.ssh/config`).

## Использование

```bash
collect-openwrt-info.sh [router] [profile] [-h | --help]
```

| Аргумент  | Описание                                                | По умолчанию |
| --------- | ------------------------------------------------------- | ------------ |
| `router`  | SSH Host из `~/.ssh/config`                             | `my-router`  |
| `profile` | Один из: `minimal`, `normal`, `full`, `crash`, `custom` | `minimal`    |

### Примеры

```bash
collect-openwrt-info.sh
collect-openwrt-info.sh my-router [minimal | normal | ...]
CUSTOM_DEFAULTS="collect_system collect_resources" collect-openwrt-info.sh my-router custom
SANITIZE=0 collect-openwrt-info.sh my-router full
collect-openwrt-info.sh -h
```

## Профили

### minimal

Максимально компактный отчёт, предназначенный для локальных LLM с небольшим контекстом.

- **System:** `ubus call system board`, `/etc/openwrt_release`, `uname`, `uptime`, `/proc/version`
- **Resources:** `free`, `df -h`, `mount`, `/proc/loadavg`
- **Storage:** `lsusb`, `block info`, `blkid`
- **Network:** `ip addr`, `ip route`, `bridge link`, `ubus call system info`
- **Configuration:** `uci export network wireless firewall dhcp system fstab`

Не включаются: `ps`, `top`, `lsmod`, `pstore`.

### normal

Содержит всё из `minimal`. Дополнительно:

- `lsmod`
- `pstore` (если каталог существует)
- `dmesg | tail`, `logread | tail`

### full

Содержит всё из `normal`. Дополнительно:

- `top -bn1`
- `ps | sort`

### crash

Специализированный профиль для расследования зависаний и сбоев.

- Увеличенный объём журналов (`LOG_LINES=1000`).
- Содержит: System, Resources, Storage, Network, `top`, `ps`, `lsmod`, `dmesg`, `logread`, `pstore`.
- Конфигурация (`uci export`) не включается.

### custom

Гибкий профиль для произвольного набора функций `collect_*`.

Набор функций задаётся переменной `CUSTOM_DEFAULTS`:

```bash
CUSTOM_DEFAULTS="collect_system collect_resources collect_network collect_logs"
```

Переменную можно переопределить через окружение:

```bash
CUSTOM_DEFAULTS="collect_system collect_storage collect_config" \
  collect-openwrt-info.sh my-router custom
```

Допустимые значения:

```
collect_system
collect_resources
collect_storage
collect_network
collect_config
collect_logs
```

- Неизвестные значения игнорируются, в отчёт выводится предупреждение.
- Дубликаты выполняются один раз, порядок выполнения — как в переменной.
- Количество строк журналов задаётся переменной `LOG_LINES`.

## Отчёт

Отчёт сохраняется в текущем каталоге. Например:

```
openwrt-debug-minimal-20260803-194520.log
```

В начале файла — шапка:

```
OpenWrt Diagnostic Report

Router:
Profile:
Date:
Privacy: sanitized
```

и оглавление с перечнем разделов. Файл отчёта создаётся с правами `600`.

## Приватность

По умолчанию отчёт **санитизируется** (маскируются чувствительные данные). Это нужно, чтобы отчёт можно было безопасно подавать в LLM или передавать третьим лицам.

Маскируются:

| Что                                                                                               | Пример                          | Результат                   |
| ------------------------------------------------------------------------------------------------- | ------------------------------- | --------------------------- |
| Ключи/пароли в UCI (`key`, `psk`, `password`, `secret`, `private_key`, `preshared_key`, `awg_i1`) | `option key '0109202309092023'` | `option key '<redacted>'`   |
| MAC-адреса (OUI/вендор сохраняется)                                                               | `24:0F:5E:01:E3:BD`             | `24:0F:5E:xx:xx:xx`         |
| IPv4 (сетевые октеты сохраняются)                                                                 | `94.41.18.209`                  | `94.41.x.x`                 |
| IPv6 (сеть сохраняется, маскируется IID)                                                          | `fe80::260f:5eff:fe01:e3bd`     | `fe80::xxxx:xxxx:xxxx:xxxx` |
| hostname, SSID                                                                                    | `RouteRich`, `rr-svvsei`        | `host`, `ssid`              |

Для диагностики сохраняются: модель, ядро, версии, память/диски/разделы, UUID блоков, топология firewall, структура маршрутов.

Управление маскированием (через окружение):

```bash
SANITIZE=0 collect-openwrt-info.sh my-router full            # сырой отчёт
MASK_MAC=0 collect-openwrt-info.sh my-router full            # без маскирования MAC
CUSTOM_DEFAULTS="collect_config" MASK_IDENT=0 \
  collect-openwrt-info.sh my-router custom                   # только конфиг без маски hostname/SSID
```

В шапке отчёта указывается режим: `Privacy: sanitized` или `Privacy: raw`.

## Конфигурация

Все параметры вынесены в переменные в начале скрипта и могут быть переопределены через окружение:

| Переменная        | Описание                          | По умолчанию                                                    |
| ----------------- | --------------------------------- | --------------------------------------------------------------- |
| `DEFAULT_ROUTER`  | Хост по умолчанию                 | `my-router`                                                     |
| `DEFAULT_PROFILE` | Профиль по умолчанию              | `minimal`                                                       |
| `SSH_TIMEOUT`     | Таймаут каждой команды, секунд    | `10`                                                            |
| `LOG_LINES`       | Количество строк журналов         | `300`                                                           |
| `CONFIG_PACKAGES` | Пакеты для `uci export`           | `network wireless firewall dhcp system fstab`                   |
| `CUSTOM_DEFAULTS` | Набор функций профиля `custom`    | `collect_system collect_resources collect_network collect_logs` |
| `SANITIZE`        | Мастер-переключатель маскирования | `1`                                                             |
| `MASK_SECRETS`    | Маскировать ключи/пароли в UCI    | `1`                                                             |
| `MASK_IPS`        | Маскировать IP-адреса             | `1`                                                             |
| `MASK_MAC`        | Маскировать MAC-адреса            | `1`                                                             |
| `MASK_IDENT`      | Маскировать hostname/SSID         | `1`                                                             |

Пример:

```bash
SSH_TIMEOUT=20 LOG_LINES=500 collect-openwrt-info.sh my-router full
```

## Завершение работы

После окончания работы скрипт выводит:

```
Finished.

Output saved to:

openwrt-debug-normal-20260803-194520.log
```

## Примечания

- Каждая команда выполняется с таймаутом. При ошибке работа скрипта продолжается, ошибка записывается в отчёт.
- `dmesg` и `logread` выводятся только последними строками (`tail -n $LOG_LINES`).
- `uci export` используется только с указанием пакета.
- Расширение: новый раздел добавляется новой функцией `collect_*`, после чего её можно включить в профили или в `CUSTOM_DEFAULTS`.
