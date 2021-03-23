SHELL := /bin/bash

PYTHON=python3.8
DJANGO_MANAGE=api/manage.py
ENV_DIR=.$(PYTHON)_env
IN_ENV=. $(ENV_DIR)/bin/activate

all:
	@./.djengu/create.sh

build-dev: env-dev build-python migrations run-django-scripts

env-dev:
	$(eval include env/.env.dev)
	$(eval export $(shell sed 's/=.*//' env/.env.dev))

env-test:
	$(eval include env/.env.test)
	$(eval export $(shell sed 's/=.*//' env/.env.test))

env-prod:
	$(eval include env/.env.prod)
	$(eval export $(shell sed 's/=.*//' env/.env.prod))

env-sub: env-prod
	@envsubst < "docker-compose.prod.yml" > "docker-compose.yml"

<<<<<<< HEAD
deploy-prod: env-prod env-sub build-frontend
=======
celery: env-dev
	$(IN_ENV) && cd api && celery -A config worker --beat -l info -S django

deploy-prod: env-prod env-sub build-prod-frontend
>>>>>>> 0a43fda (Auth is working, but not SSR)
	echo "Building ${ENVIRONMENT} Environment"
	docker-compose up --build

build-python:
	virtualenv -p $(PYTHON) $(ENV_DIR)
	$(IN_ENV) && pip3 install -r api/requirements.txt

<<<<<<< HEAD
build-frontend:
	cd frontend && npm i && npx quasar build -m ssr
=======
build-frontend: env-dev
	cd frontend && npm i && quasar build -m ssr

build-prod-frontend: env-prod
	cd frontend && npm i && quasar build -m ssr
>>>>>>> 0a43fda (Auth is working, but not SSR)

backend-serve: env-dev migrations
	$(IN_ENV) && python $(DJANGO_MANAGE) runsslserver

frontend-serve: env-dev
	cd frontend && quasar dev -m ssr

frontend-prod-serve: env-prod
	cd frontend/dist/ssr/ && npm run start

run-django-scripts: env-dev
	@$(IN_ENV) && python $(DJANGO_MANAGE) runscript create_test_users

migrations: env-dev
	$(IN_ENV) && python $(DJANGO_MANAGE) makemigrations --noinput
	$(IN_ENV) && python $(DJANGO_MANAGE) migrate --noinput

flush-the-database-yes-really: env-dev
	$(IN_ENV) && python $(DJANGO_MANAGE) flush

test: env-test build-python
	$(IN_ENV) && $(PYTHON) -m pytest api/tests/

encrypt-dotenv:
	tar -c env/ | gpg --symmetric -c -o env.tar.gpg

decrypt-dotenv: env-dev
	gpg --quiet --batch --yes --decrypt --passphrase=ENCRYPTION_KEY env.tar.gpg | tar -x

configure-vagrant:
	@sudo ./.djengu/.production_toolbox/configure_vagrant.sh
	@./.djengu/.production_toolbox/caddy/vagrant_caddy.sh

<<<<<<< HEAD
clean:
=======
clean-env:
>>>>>>> aeaded1 (Auth is finally working)
	@rm -rf $(ENV_DIR)
	@rm -rf node_modules frontend/node_modules
	@rm -rf package-lock.json frontend/package-lock.json
	@rm -rf frontend/dist
	@rm -rf .pytest_cache
	@echo "Environment cleaned."
