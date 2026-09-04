#!/usr/bin/env bash

# post_deploy.sh - 配置文件部署后安装常用 Homebrew/Linuxbrew 包
# 用法：在 dotter deploy 后执行此脚本
#
# 环境变量:
#   DOTTER_SKIP_BREW=1  - 跳过 Homebrew 包安装

if [ "${DOTTER_SKIP_BREW}" = "1" ] || [ "${DOTTER_SKIP_BREW}" = "true" ]; then
    echo "⏭️  Post-deployment: 跳过 Homebrew 包安装 (DOTTER_SKIP_BREW=${DOTTER_SKIP_BREW})"
    exit 0
fi

set -e

OS=$(uname)

echo "📦 Post-deployment: Installing Homebrew packages..."

# 检测 Homebrew/Linuxbrew 路径
if [ "$OS" == "Darwin" ]; then
    HOMEBREW_PREFIX="/opt/homebrew"
    HOMEBREW_BIN="/opt/homebrew/bin/brew"
elif [ "$OS" == "Linux" ]; then
    HOMEBREW_PREFIX="$HOME/.linuxbrew"
    HOMEBREW_BIN="$HOME/.linuxbrew/bin/brew"
else
    echo "❌ Unknown OS: $OS"
    exit 1
fi

echo "🔍 Using Homebrew at: $HOMEBREW_BIN"

# 检查 brew 是否可用
if ! command -v "$HOMEBREW_BIN" &> /dev/null; then
    echo "❌ Homebrew not found at $HOMEBREW_BIN"
    exit 1
fi

# 包定义函数
install_packages() {
    local pkg_type="$1"
    shift
    local packages=("$@")

    if [ ${#packages[@]} -eq 0 ]; then
        return
    fi

    echo ""
    echo "📦 Installing $pkg_type packages..."
    for pkg in "${packages[@]}"; do
        echo "  → $pkg"
        "$HOMEBREW_BIN" install "$pkg" 2>/dev/null || echo "    ⚠️  Already installed or failed: $pkg"
    done
}

# macOS 通用包
macos_core=(
    "fish"
    "starship"
    "tmux"
    "bat"
    "eza"
    "fd"
    "fzf"
    "ripgrep"
    "tree"
    "bottom"
    "btop"
    "procs"
    "gdu"
    "ncdu"
    "direnv"
    "zoxide"
    "lnav"
    "gh"
    "git"
    "git-lfs"
    "git-delta"
    "git-filter-repo"
    "git-fixup"
    "uv"
    "wget"
    "xh"
    "yq"
    "dotter"
    "herdr"
)

# macOS Cask 包（GUI 应用）
macos_casks=(
    "alacritty"
    "kitty"
    "visual-studio-code"
    "zed@preview"
)

# 语言服务器（配合 Helix/Neovim/Zed）
macos_lsp=(
    "basedpyright"
    "pyright"
    "bash-language-server"
    "fish-lsp"
    "marksman"
    "taplo"
    "vscode-langservers-extracted"
    "yaml-language-server"
    "sql-language-server"
    "dockerfile-language-server"
    "prettier"
)

# AI 编码工具
ai_tools=(
    "anomalyco/tap/opencode"
    "openspec"
    "github-mcp-server"
    "context7-mcp"
    "playwright-mcp"
    "mimo-code"
)

# Linux 通用包
linux_core=(
    "fish"
    "starship"
    "tmux"
    "bat"
    "eza"
    "fd"
    "fzf"
    "ripgrep"
    "tree"
    "bottom"
    "btop"
    "procs"
    "gdu"
    "ncdu"
    "direnv"
    "zoxide"
    "lnav"
    "gh"
    "git"
    "git-lfs"
    "git-delta"
    "git-filter-repo"
    "git-fixup"
    "uv"
    "wget"
    "xh"
    "yq"
    "pre-commit"
    "ast-grep"
    "dotter"
    "neovim"
)

# 额外的 macOS 专用包
macos_extras=(
    "obsidian"
    "docker"
    "helix"
    "neovim"
)

# 额外的 Linux 专用包
linux_extras=(
    "btop"
    "htop"
    "ncdu"
)

# 开发工具包（可选）
dev_tools=(
    "cmake"
    "rustup"
    "go"
    "node"
    "python"
)

# 根据操作系统安装包
if [ "$OS" == "Darwin" ]; then
    echo "🍎 Detected macOS"
    install_packages "core" "${macos_core[@]}"
    install_packages "lsp" "${macos_lsp[@]}"
    install_packages "ai" "${ai_tools[@]}"

    # 检查是否安装 cask
    read -p "📱 Install GUI applications (casks)? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_packages "casks" "${macos_casks[@]}"
    fi

    # 询问额外包
    read -p "🛠️  Install extra macOS packages? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_packages "extras" "${macos_extras[@]}"
    fi

elif [ "$OS" == "Linux" ]; then
    echo "🐧 Detected Linux"
    install_packages "core" "${linux_core[@]}"

    # 询问额外包
    read -p "🛠️  Install extra Linux packages? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_packages "extras" "${linux_extras[@]}"
    fi
fi

# 询问开发工具
read -p "💻 Install development tools (cmake, rustup, go, node, python)? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_packages "dev" "${dev_tools[@]}"
fi

# 更新 Homebrew
echo ""
echo "🔄 Updating Homebrew..."
"$HOMEBREW_BIN" update

# 清理旧版本
echo ""
echo "🧹 Cleaning up old versions..."
"$HOMEBREW_BIN" cleanup

echo ""
echo "✅ Post-deployment complete!"
echo ""
echo "📋 Summary:"
echo "   Core packages: Installed"
echo "   OS type: $OS"
echo "   Homebrew: Updated"
echo ""
echo "💡 Tip: You can customize this script in .dotter/post_deploy.sh"
