set -g fish_term24bit 1

# 根据平台设置编辑器
if test (uname) = Darwin
    set -gx EDITOR /opt/homebrew/bin/code
else
    set -gx EDITOR hx
end

# 环境变量
set -gx PIER_CONFIG_PATH $HOME/.config/pier/pier.toml
set -gx HOMEBREW_BREW_GIT_REMOTE https://mirrors.ustc.edu.cn/brew.git
set -gx FZF_DEFAULT_COMMAND "fd --type file --color=always"
set -gx SSH_AUTH_SOCK "~/.ssh/agent"
set -gx DEFAULT_MVN_VERSION 3.6.3
set -gx OPENCODE_EXPERIMENTAL_LSP_TY 1
set -gx OPENCODE_MODEL wolf-ai/ack-dev
set -gx OPENCODE_GEMINI_PRO_MODEL google/antigravity-gemini-3-pro
set -gx OPENCODE_GEMINI_FLASH_MODEL google/antigravity-gemini-3-flash
set -gx OPENCODE_CLAUDE_MODEL google/antigravity-claude-sonnet-4-5-thinking
set -gx RUSTUP_DIST_SERVER https://rsproxy.cn
set -gx RUSTUP_UPDATE_ROOT https://rsproxy.cn/rustup
set -gx OPENCODE_PORT 4096
