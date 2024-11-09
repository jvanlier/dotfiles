FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends sudo \
  && rm -rf /var/lib/apt/lists/* \
  && useradd -m -s /bin/bash test \
  && usermod -aG sudo test \
  && echo "test ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/test

USER test

COPY . .

ARG SKIP_PYENV
ENV SKIP_PYENV=$SKIP_PYENV

RUN bash ./bootstrap-ubuntu.sh

# YouCompleteMe unavailable: requires Vim 9.1.0016+.
# Installed = v9.0
