GUNICORN_PORT ?= 5000

install:
	@printf "$(OK_COLOR)Installing dependencies...$(NO_COLOR)\n"
	@pip install -r requirements.txt

start:
	@printf "$(OK_COLOR)Starting salsa runserver$(NO_COLOR)\n"
	@python3 manage.py runserver

migrate-mark:
	@python3 manage.py db migrate

migrate-up:
	@python3 manage.py db upgrade

db-reset:
	@python3 manage.py drop_db
	@python3 manage.py create_db
	PGPASSWORD=salsa psql -d salsa-${ENVIRONMENT} -h ${PGHOST} -U salsa -c 'ALTER SCHEMA public OWNER TO salsa;'
	@python3 manage.py db upgrade
	PGPASSWORD=salsa psql -d salsa-${ENVIRONMENT} -f salsa/db/salsa.sql -h ${PGHOST} -U salsa


start-gunicorn:
	gunicorn -b 0.0.0.0:${GUNICORN_PORT} --access-logfile - --error-logfile - salsa.app:app

# db-seed:
# 	PGPASSWORD=salsa psql -d salsa-${ENVIRONMENT} -f salsa/db/salsa.sql -h ${PGHOST} -U salsa

test: db-reset unit

unit:
	@printf "$(OK_COLOR)Running unit tests ...$(NO_COLOR)\n"
	@export ENVIRONMENT=testing; python3 -m unittest discover -s ./tests/unit/ -v
