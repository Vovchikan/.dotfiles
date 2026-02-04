
# Install
first-init: venv setup-env insert_aliases
	. ~/.bashrc

# Настройка окружения для Python скриптов
venv: venv/touchfile

venv/touchfile: config/requirements.txt
	test -d venv || python3 -m venv venv
	. venv/bin/activate; pip install -Ur config/requirements.txt
	touch venv/touchfile

requirements:
	. venv/bin/activate; pip freeze > config/requirements.txt

# Создание файла ~/.my_scripts.conf
setup-env:
	config/setup_env.py

# Добавление баш алиасов
insert-aliases:
	config/insert_aliases.py -s scripts/bash_aliases