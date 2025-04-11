# syntax=docker/dockerfile:1.4
FROM --platform=$BUILDPLATFORM ext-docker-dev-local/redhat/ubi9/python-39:latest AS builder

USER root
RUN rm -f /etc/yum.repos.d/ubi.repo 
RUN dnf update -y

WORKDIR /code
COPY requirements.txt /code
COPY setuptools-78.1.0.tar.gz /code
COPY markupsafe-3.0.2.tar.gz /code
COPY jinja2-3.1.6-py3-none-any.whl /code
COPY itsdangerous-2.2.0-py3-none-any.whl /code
COPY click-8.1.8-py3-none-any.whl /code
COPY blinker-1.9.0-py3-none-any.whl /code
COPY flask-3.1.0-py3-none-any.whl /code
COPY redis-5.2.1-py3-none-any.whl /code
COPY werkzeug-3.1.3-py3-none-any.whl /code

+/simple/importlib-metadata/

WORKDIR /code
RUN tar xzvf setuptools-78.1.0.tar.gz
RUN pip install --no-index --find-links=/code setuptools
RUN tar xzvf markupsafe-3.0.2.tar.gz
RUN pip install --no-index --find-links=/code markupsafe
RUN pip install ./werkzeug-3.1.3-py3-none-any.whl
RUN pip install ./jinja2-3.1.6-py3-none-any.whl
RUN pip install ./click-8.1.8-py3-none-any.whl
RUN pip install ./itsdangerous-2.2.0-py3-none-any.whl
RUN pip install ./blinker-1.9.0-py3-none-any.whl
RUN pip install ./flask-3.1.0-py3-none-any.whl
RUN pip install ./redis-5.2.1-py3-none-any.whl


COPY . /code

ENTRYPOINT ["python3"]
CMD ["app.py"]

FROM builder as dev-envs

RUN <<EOF
dnf update
dnf add git bash
EOF

RUN <<EOF
addgroup -S docker
adduser -S --shell /bin/bash --ingroup docker vscode
EOF
# install Docker tools (cli, buildx, compose)
COPY --from=gloursdocker/docker / /
