set -g fish_term24bit 1

# 根据平台设置编辑器
if test (uname) = "Darwin"
    set -gx EDITOR /opt/homebrew/bin/code
else
    set -gx EDITOR vim
end

# 环境变量
set -gx PIER_CONFIG_PATH $HOME/.config/pier/pier.toml
set -gx HOMEBREW_BREW_GIT_REMOTE https://mirrors.ustc.edu.cn/brew.git
set -gx FZF_DEFAULT_COMMAND "fd --type file --color=always"
set -gx SSH_AUTH_SOCK "~/.ssh/agent"
set -gx DEFAULT_MVN_VERSION 3.6.3
