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

# Verify nvim starts without segfault.
RUN nvim --version

# Verify tree-sitter CLI runs (glibc compat check — prebuilt v0.25+ need GLIBC_2.39,
# Debian 12 bookworm only has 2.36; bootstrap must pick a compatible version).
RUN "$HOME/.local/bin/tree-sitter" --version

# Verify at least one treesitter parser was compiled by the headless presync.
RUN test "$(ls "$HOME/.local/share/nvim/site/parser/" 2>/dev/null | wc -l)" -gt 0 \
    || (echo "ERROR: no treesitter parsers compiled — check tree-sitter CLI glibc compat" && exit 1)

# YouCompleteMe unavailable: requires Vim 9.1.0016+.
# Installed = v9.0
