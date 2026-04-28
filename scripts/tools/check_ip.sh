#!/usr/bin/env bash

# Создаем ассоциативный массив: имя сервиса => URL
declare -A services=(
  ["ident.me"]="http://ident.me"
  ["wgetip.com"]="http://wgetip.com"
  ["ip.tyk.nu"]="http://ip.tyk.nu"
)

# Вывод заголовка таблицы
printf "%-15s | %-45s\n" "Service" "IP Address"
printf "%s\n" "----------------+---------------------------------------------"

# Опрашиваем каждый сервис и выводим результат в табличной строке
for name in "${!services[@]}"; do
  ip=$(wget -qO- "${services[$name]}" 2>/dev/null)
  printf "%-15s | %-45s\n" "$name" "$ip"
done
