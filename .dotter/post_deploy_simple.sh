#!/usr/bin/env bash

# 简化版 post 部署脚本 - 非交互式安装常用包
# 用法：.dotter/post_deploy.sh

set -e

OS=$(uname)

echo "📦 Post-deployment: Installing essential Homebrew packages..."

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

# macOS 核心包
macos_packages=(
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
    "procs"
    "gdu"
    "direnv"
    "gh"
    "git-delta"
    "uv"
)

# Linux 核心包
linux_packages=(
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
    "procs"
    "gdu"
    "direnv"
    "gh"
    "git-delta"
    "uv"
    "neovim"
)

# 根据操作系统安装包
if [ "$OS" == "Darwin" ]; then
    echo "🍎 Detected macOS"
    install_packages "core" "${macos_packages[@]}"

elif [ "$OS" == "Linux" ]; then
    echo "🐧 Detected Linux"
    install_packages "core" "${linux_packages[@]}"
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
echo "💡 For interactive version with more options, use: .dotter/post_deploy.sh"
