#!/usr/bin/env bash

# post_deploy.sh - 配置文件部署后安装常用 Homebrew/Linuxbrew 包
# 用法：在 dotter deploy 后执行此脚本

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
    "procs"
    "gdu"
    "direnv"
    "gh"
    "git-delta"
    "git-filter-repo"
    "uv"
)

# macOS Cask 包（GUI 应用）
macos_casks=(
    "alacritty"
    "kitty"
    "wez/wez/wezterm"
    "visual-studio-code"
    "iterm2"
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
    "procs"
    "gdu"
    "direnv"
    "gh"
    "git-delta"
    "git-filter-repo"
    "uv"
    "wez/wez/wezterm"
    "neovim"
)

# 额外的 macOS 专用包
macos_extras=(
    "rectangle"
    "obsidian"
    "docker"
    "docker-compose"
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
