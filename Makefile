# Настройка окружения для Python скриптов
venv: venv/touchfile

venv/touchfile: config/requirements.txt
	test -d venv || python3 -m venv venv
	. venv/bin/activate; pip install -Ur config/requirements.txt
	touch venv/touchfile

requirements:
	. venv/bin/activate; pip freeze > config/requirements.txt