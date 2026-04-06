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
just link-configurations
```

### Папка scripts

Содержит полезные скрипты и готовые алиасы.

Команда `just setup-env` добавляет переменную `$MYSCRIPTS`, в которой записан путь к этой папке. Через эту переменную можно вызывать скрипты из этой папки:

```shell
$MYSCRIPTS/create-755.sh --help
```

Подобнее - [тут](scripts/README.md).

### Папка configure_scripts

Подобнее - [тут](configure_scripts/README.md).

### Команды Makefile

| Команда             | Описание                                                                                      |
| ------------------- | --------------------------------------------------------------------------------------------- |
| `make venv`         | Создаёт Python venv в папке `./venv` и устанавливает зависимости из `config/requirements.txt` |
| `make requirements` | Обновляет `config/requirements.txt` на основе текущего окружения                              |

### Примеры конфигов

#### Neovim

[Example](https://gist.github.com/nat-418/493d40b807132d2643a7058188bff1ca)

#### Tmux

[Readme](tmux/README.md)

#### Zed

[Example](https://gist.github.com/kofta999/77fe78491830da3c7e252ceb2857e37c)

## 📋 [TODO](./TODO.md)