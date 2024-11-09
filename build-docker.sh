#!/usr/bin/env bash
set -ex

echo "Skipping pyenv"
docker build --tag dotfiles-ubuntu24 --build-arg SKIP_PYENV=1 -f docker/ubuntu-24-lts/Dockerfile .
docker build --tag dotfiles-debian12 --build-arg SKIP_PYENV=1 -f docker/debian-12-bookworm/Dockerfile .

echo "Not skipping pyenv"
docker build --tag dotfiles-ubuntu24-pyenv -f docker/ubuntu-24-lts/Dockerfile .
docker build --tag dotfiles-debian12-pyenv -f docker/debian-12-bookworm/Dockerfile .
