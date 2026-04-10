# TODO

- [x] Добавить настройку `sudo update-alternatives --config editor`
- [x] Добавить скрипт для линковки конфигов. Пример можно взять из `./vim/link.sh`
- [x] Перейти с `make` на `just`?
- [x] Добавить конфигурацию для mc
- [x] Вернуть конфигурацию для konsole?
- [ ] Сохранение настроек KeepassXC?
- [x] Протестировать just `rename-home-dirs` на не нужной системе. Что будет если папки уже на английском и в них есть данные?
- [ ] (Ошибка) При чистой установке yt-dlp.sh не видит deno, потому что его нет в path без перезагрузки терминала (?)
- [ ] Отрефакторить `vscode.sh`
  - [ ] Создать функцию установки расширения из github для vscode по примеру `install-nefrob.vscode-just`
  - [ ] Попробовать добавить установку [расширения для ini-файлов](https://marketplace.visualstudio.com/items?itemName=DavidWang.ini-for-vscode)
