# TODO

- [x] Добавить настройку `sudo update-alternatives --config editor`
- [x] Добавить скрипт для линковки конфигов. Пример можно взять из `./vim/link.sh`
- [x] Перейти с `make` на `just`?
- [x] Добавить конфигурацию для mc
- [x] Вернуть конфигурацию для konsole?
- [ ] Сохранение настроек KeepassXC?
- [x] Протестировать just `rename-home-dirs` на не нужной системе. Что будет если папки уже на английском и в них есть данные?
- [ ] (⚠️ Ошибка) Razer не устанавливается, не подставляется версия системы
- [ ] (Исправить) При чистой установке yt-dlp.sh не видит deno, потому что его нет в path без перезагрузки терминала (?)
- [ ] Отрефакторить `install_scripts/main.sh` и `configure/main.sh`: убрать интерактивность при SSH-деплое
  - [ ] Флаг `--non-interactive` (или `-y`) — пропускать все `read -p` блоки
  - [ ] Аргумент `--config <file.json>` — предопределённые ответы:
    ```json
    { "snap_apps": true, "postgres": false, "razer": false, ... }
    ```
  - [ ] Каждая интерактивная секция проверяет: флаг → JSON-конфиг → stdin
  - [ ] `sudo update-alternatives --config editor` — тоже неинтерактивный режим
- [x] Отрефакторить `vscode.sh`
  - [x] Создать функцию установки расширения из github для vscode по примеру `install-nefrob.vscode-just`
  - [x] Реализовать функцию установки расширений без GitHub Releases (сборка из исходников)
  - [x] Проверить функцию на [расширении для ini-файлов](https://github.com/daviduuang/ini-for-vscode)
