# Настройка окружения для Python скриптов
venv: venv/touchfile

venv/touchfile: helpers/requirements.txt
	test -d venv || python3 -m venv venv
	. venv/bin/activate; pip install -Ur helpers/requirements.txt
	touch venv/touchfile

requirements:
	. venv/bin/activate; pip freeze > helpers/requirements.txt