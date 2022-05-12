FROM docker.io/library/python:3.10.4-bullseye

RUN apt-get update -y
RUN apt-get install -y --no-install-recommends net-tools telnet

RUN curl -sSL --fail https://raw.githubusercontent.com/pdm-project/pdm/main/install-pdm.py | python3 -

COPY pyproject.toml pdm.lock /tmp/build/
COPY app.py /tmp/build/

WORKDIR /tmp/build
RUN /root/.local/bin/pdm install --prod --global --no-editable --project /tmp/build
RUN rm -rf /tmp/build

RUN rm -rf /root/.local

WORKDIR /root
