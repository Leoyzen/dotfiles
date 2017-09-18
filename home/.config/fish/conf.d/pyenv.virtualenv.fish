#!/usr/bin/env bash
set -x PATH $HOME/.pyenv/bin $PATH
set -x PYENV_ROOT $HOME/.pyenv
set -x VIRTUAL_ENV_DISABLE_PROMPT 1
set -x PYTHON_BUILD_MIRROR_URL http://mirrors.sohu.com/python/

status --is-interactive; source (pyenv init -|psub)
status --is-interactive; source (pyenv virtualenv-init -|psub)
