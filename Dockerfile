FROM python:3.7

RUN apt-get update && apt-get install -y postgresql-client

RUN mkdir -p /opt/couyang/salsa
WORKDIR /opt/couyang/salsa

RUN pip3 install --upgrade pip
COPY requirements*.txt ./
RUN pip3 install -r requirements.txt

# Copy project to container
COPY . ./

LABEL maintainer="Charlie Ou Yang <charlieouyang@gmail.com>"
LABEL source="salsa@salsa.com"
ARG commit
LABEL commit="$commit"

ENV PORT 5000

# For working pocoo click support. See http://click.pocoo.org/5/python3/
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV PYTHONPATH=.

COPY ops/gunicorn.py ops/

CMD make start
