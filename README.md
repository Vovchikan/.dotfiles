# dotfiles

Мои настройки и скрипты для чистой системы.

---

## Подготовка

### Скачивание репозитория

```shell
git clone https://github.com/Vovchikan/.dotfiles.git
cd .dotfiles
git submodule update --init --recursive # если есть доступ
```

### Установка Зависимостей

```shell
sudo apt install -y "python3.*-venv" build-essential
snap install --edge --classic just
just venv
just setup-env
just insert-aliases
```

> [!TIP]
> Более подробная информация о командах just: `just` или `just --list`.

---

## Использование

### Установка приложений

```shell
just install
```

### Настройка приложений

```shell
just configure
just link-configs
just merge-configs
```

### Папка scripts

Содержит полезные скрипты в папке `tools` и готовые алиасы в папке `aliases`.

Команда `just setup-env` добавляет переменную `$MYSCRIPTS`, в которой записан путь к этой папке. Через эту переменную можно вызывать скрипты из этой папки:

```shell
$MYSCRIPTS/tools/create-755.sh --help
```

Подобнее - [тут](scripts/README.md).

### Папка configure

Подобнее - [тут](configure/README.md).

### Команды Makefile

| Команда             | Описание                                                                                       |
| ------------------- | ---------------------------------------------------------------------------------------------- |
| `make venv`         | Создаёт Python venv в папке `./venv` и устанавливает зависимости из `helpers/requirements.txt` |
| `make requirements` | Обновляет `helpers/requirements.txt` на основе текущего окружения                              |

## Конфиги

### [Vim](app_configs/vim/README.md)

### [Tmux](app_configs/tmux/README.md)

### [Midnight Commander](app_configs/mc/README.md)

## Примеры конфигов

#### Neovim

[Example](https://gist.github.com/nat-418/493d40b807132d2643a7058188bff1ca)

#### Zed

[Example](https://gist.github.com/kofta999/77fe78491830da3c7e252ceb2857e37c)

## 📋 [TODO](./TODO.md)

---

## Тестирование

Скрипты для тестирования находятся в папке `tests/`.

Основные команды:

| Команда                  | Что делает                                     |
| ------------------------ | ---------------------------------------------- |
| `just test`              | Проверить текущий хост (`--live`)              |
| `just test-sandbox`      | Проверить в изолированном `$HOME`              |
| `just test-vm`           | Задеплоить + протестировать headless ВМ        |
| `just test-vm-desktop`   | Реверт снапшота + деплой + тесты на desktop ВМ |
| `just test-vm-fullcycle` | Создать → протестировать → удалить headless ВМ |

IP-адреса ВМ определяются автоматически.
SSH host key не запрашивается (`StrictHostKeyChecking=accept-new`).

### Архитектура

Тесты работают в двух режимах:

- **`--live`** — проверяет текущее состояние хоста без изменений.
  Подходит для быстрой проверки, что все конфиги и алиасы на месте.
  Результат зависит от того, какие приложения установлены на хосте.
  Например, Konsole будет проверен только на KDE-системе.

- **`--sandbox`** — создаёт временный `$HOME`, применяет к нему рецепты
  (link-configs, setup-env, insert-aliases, git config), запускает
  тесты, затем удаляет sandbox.

### Область применения

- **`--sandbox`** — изолированная проверка конфигов, алиасов и переменных
  окружения без изменения реального `$HOME`. Для локальной разработки.
- **`--live`** — проверка текущего состояния хоста (или ВМ). Тесты Konsole
  пройдут только на KDE; это нормальное поведение.
- **На ВМ** тесты работают в режиме `--live` — конфиги применяются к реальному
  `$HOME` пользователя `testuser`. Это даёт максимально реалистичную проверку:
  настройка Git, симлинки, алиасы, переменные окружения — всё как на реальной
  системе.
- **Установка приложений (`just install`)** пока не тестируется на ВМ из-за
  интерактивных диалогов. Задача на доработку в `TODO.md`.

### Требования

- `just` — для запуска тестов на хосте
- Для создания ВМ: `virt-install`, `virsh`, `genisoimage`, `curl`, `sudo`
- Для графического подключения к desktop ВМ: `virt-manager` (для консоли)
- SSH-ключ `~/.ssh/id_ed25519.pub` (по умолчанию; можно переопределить через `$SSH_KEY`)

### Создание виртуальной машины

Скрипт `tests/vm/create.sh` автоматизирует создание тестовой ВМ через `virt-install`.

1. **Образ**: Ubuntu 24.04 Server cloud image загружается с
   `cloud-images.ubuntu.com` и кэшируется в `~/.cache/dotfiles-test/`.
2. **Диск**: образ копируется в `/var/lib/libvirt/images/` (для доступа QEMU),
   после чего создаётся qcow2-диск с backing store (copy-on-write — экономит
   место и ускоряет создание).
3. **Cloud-init**: генерируется ISO-образ с:
   - пользователем `testuser` (sudo без пароля)
   - вашим публичным SSH-ключом
   - пакетами `just`, `python3`, `git`, `qemu-guest-agent`
4. **Запуск**: `virt-install --import --noautoconsole --wait=0`. ВМ загружается
   и через cloud-init настраивает систему. Скрипт ожидает получения IP-адреса.

Доступно два варианта:

| Параметр     | Headless (по умолчанию) | Desktop (`--desktop`)                                    |
| ------------ | ----------------------- | -------------------------------------------------------- |
| Имя ВМ       | `dotfiles-test`         | `dotfiles-test-desktop`                                  |
| RAM          | 4 GB                    | 8 GB                                                     |
| Размер диска | 30 GB                   | 80 GB                                                    |
| Графика      | `--graphics none`       | SPICE                                                    |
| Доп. пакеты  | —                       | KDE Plasma, Konsole, Dolphin, pavucontrol, spice-vdagent |
| Для чего     | vim, tmux, mc, zed      | Konsole, qBittorrent, GUI                                |
| Snapshot     | нет                     | `clean` после первого запуска                            |

### Snapshot workflow (Desktop)

Desktop ВМ создаётся один раз, после чего снапшотится. Каждый последующий
запуск тестов просто откатывается к чистому снапшоту — это быстро (секунды).

**Первый запуск:**

1. `just test-vm-desktop` → скрипт видит, что снапшота нет
2. `tests/vm/create.sh --desktop` — создаёт ВМ, ждёт окончания cloud-init
3. Cloud-init устанавливает KDE Plasma (5–15 мин)
4. Создаётся снапшот `clean`, ВМ выключается
5. Реверт из снапшота → `just test-vm` → деплой, конфиги, тесты

**Последующие запуски:**

1. `just test-vm-desktop` → снапшот есть, реверт (1–2 сек)
2. ВМ загружается (чистая система, готовность за 5–10 сек)
3. Тесты накатываются автоматически
4. ВМ остаётся работать для инспекции (независимо от результата)
5. Следующий реверт вернёт её к чистому состоянию

### Что тестируется

| Suite            | Что проверяет                                             |
| ---------------- | --------------------------------------------------------- |
| `test_links`     | symlink'ы vim, tmux, mc, konsole                          |
| `test_aliases`   | алиасы из `scripts/aliases/bash_aliases`                  |
| `test_configure` | git config (user.name, pull.ff, алиасы hide/assume и др.) |
| `test_env`       | `~/.my_scripts.conf`, `$MYSCRIPTS`, `$WORKSCRIPTS`        |

### Как это работает под капотом

**Локальные тесты:**

- `just test` — `./tests/run.sh --live` (проверка текущего `$HOME` без изменений)
- `just test-sandbox` — `./tests/run.sh --sandbox` (изолированная копия `$HOME`
  для безопасной разработки)

**Headless VM (`just test-vm`):**

1. **IP обнаружение**: рецепт сам находит IP через `virsh domifaddr dotfiles-test`
   (по DHCP), никаких ручных адресов.
2. **Упаковка**: `git ls-files -c -o --exclude-standard` формирует список
   файлов, `tar` создаёт архив в `/tmp/dotfiles.tar.gz`.
3. **Доставка**: SCP на ВМ с `StrictHostKeyChecking=accept-new` — без вопросов
   про host key, даже если ВМ пересоздана.
4. **Деплой**: архив распаковывается в `~/dotfiles/` на ВМ.
5. **Применение конфигов** (в реальный `$HOME` пользователя):
   - `just configure-git` — настройка Git
   - `just link-configs` — симлинки конфигов
   - `just setup-env` — `~/.my_scripts.conf`
   - `just insert-aliases` — алиасы в `.bashrc`
6. **Тесты**: `./tests/run.sh --live` проверяет, что всё применилось.

**Desktop VM (`just test-vm-desktop`):**

1. Проверяется наличие снапшота `clean` у `dotfiles-test-desktop`
2. Если снапшота нет — создаётся ВМ с `create.sh --desktop`,
   ожидается cloud-init (KDE Plasma установка), создаётся снапшот, ВМ выключается
3. Если снапшот есть — реверт к нему (ВМ включается за секунды)
4. Выполняется `just test-vm testuser dotfiles-test-desktop` — IP, деплой, тесты,
   всё автоматически
5. ВМ остаётся запущенной для инспекции через SSH или virt-manager
6. Следующий `just test-vm-desktop` снова ревертнёт её к чистому состоянию