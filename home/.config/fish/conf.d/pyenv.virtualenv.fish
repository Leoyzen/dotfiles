#!/usr/bin/env bash
set -x PYENV_ROOT $HOME/.pyenv
set -x VIRTUAL_ENV_DISABLE_PROMPT 1
set -x PYTHON_BUILD_MIRROR_URL http://mirrors.sohu.com/python/

status --is-interactive; and source < (pyenv init -|psub)
status --is-interactive; and source < (pyenv virtualenv-init -|psub)
