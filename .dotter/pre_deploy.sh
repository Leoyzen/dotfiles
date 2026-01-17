#!/usr/bin/env bash

# pre_deploy.sh - Dotter 部署前脚本
# 功能：检测并安装 Homebrew/Linuxbrew（使用清华镜像）

OS=$(uname)

echo "🔍 Pre-deployment: Checking and installing Homebrew..."

# 检测 Homebrew/Linuxbrew 是否已安装
check_brew() {
    if [ "$OS" == "Darwin" ]; then
        if [ -x "/opt/homebrew/bin/brew" ]; then
            return 0
        fi
    elif [ "$OS" == "Linux" ]; then
        if [ -x "$HOME/.linuxbrew/bin/brew" ]; then
            return 0
        elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
            return 0
        fi
    fi
    return 1
}

# 安装 Homebrew/Linuxbrew
install_brew() {
    local OS_TYPE="$1"
    local HOMEBREW_PREFIX="$2"
    local HOMEBREW_BIN="$3"
    local INSTALL_DIR="$4"

    echo ""
    echo "📦 Homebrew not found. Installing from Tsinghua mirror..."
    echo "   OS: $OS_TYPE"
    echo "   Prefix: $HOMEBREW_PREFIX"
    echo "   Mirror: https://mirrors.tuna.tsinghua.edu.cn"
    echo ""

    # 设置镜像环境变量
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
    export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"

    # 检查必要工具
    if ! command -v git &> /dev/null; then
        echo "❌ git not found. Please install git first."
        exit 1
    fi

    if ! command -v curl &> /dev/null; then
        echo "❌ curl not found. Please install curl first."
        exit 1
    fi

    # macOS 需要检查 Xcode Command Line Tools
    if [ "$OS" == "Darwin" ]; then
        if ! command -v xcode-select &> /dev/null || ! xcode-select -p &> /dev/null; then
            echo "⚠️  Xcode Command Line Tools not found."
            echo "   Please install with: xcode-select --install"
            exit 1
        fi
    fi

    # 从清华镜像克隆安装脚本
    echo "📥 Cloning Homebrew install script from Tsinghua mirror..."
    git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git "$INSTALL_DIR"

    # 运行安装脚本
    echo "🔧 Running Homebrew installer..."
    /bin/bash "$INSTALL_DIR/install.sh"

    # 清理临时文件
    rm -rf "$INSTALL_DIR"

    echo ""
    echo "✅ Homebrew installed successfully!"
    echo ""
    echo "📋 Next steps:"
    if [ "$OS" == "Darwin" ]; then
        echo "   1. Run: eval \"\$(/opt/homebrew/bin/brew shellenv)\""
        echo "   2. Or add to your shell profile:"
        echo "      echo 'eval \"\$(/opt/homebrew/bin/brew shellenv)\"' >> ~/.zprofile"
    elif [ "$OS" == "Linux" ]; then
        echo "   1. Run: eval \"\$(~/.linuxbrew/bin/brew shellenv)\""
        echo "   2. Or add to your shell profile:"
        echo "      echo 'eval \"\$(~/.linuxbrew/bin/brew shellenv)\"' >> ~/.bash_profile"
    fi
    echo ""
    echo "💡 The mirror settings will be configured in shell profile"
    echo "   See docs/brew-packages.md for package management."
}

# 根据操作系统设置参数并安装
if [ "$OS" == "Darwin" ]; then
    echo "🍎 Detected macOS"

    if check_brew; then
        echo "✅ Homebrew already installed at /opt/homebrew/bin/brew"
    else
        install_brew "macOS" "/opt/homebrew" "/opt/homebrew/bin/brew" "/tmp/homebrew-install"
    fi

elif [ "$OS" == "Linux" ]; then
    echo "🐧 Detected Linux"

    # 检查用户主目录或系统目录的 linuxbrew
    if check_brew; then
        echo "✅ Linuxbrew already installed"
    else
        # 尝试安装到用户主目录
        install_brew "Linux" "$HOME/.linuxbrew" "$HOME/.linuxbrew/bin/brew" "/tmp/linuxbrew-install"
    fi

else
    echo "❌ Unknown OS: $OS"
    echo "   This script supports macOS (Darwin) and Linux only."
    exit 1
fi

# 设置镜像源（如果 brew 已安装）
if check_brew; then
    echo ""
    echo "🔧 Configuring Tsinghua mirror for Homebrew..."
    
    if [ "$OS" == "Darwin" ]; then
        # macOS 的配置文件
        if [ -f ~/.zprofile ]; then
            if ! grep -q "HOMEBREW_BREW_GIT_REMOTE" ~/.zprofile; then
                echo "" >> ~/.zprofile
                echo "# Homebrew Tsinghua mirror" >> ~/.zprofile
                echo "export HOMEBREW_BREW_GIT_REMOTE=\"https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git\"" >> ~/.zprofile
                echo "export HOMEBREW_CORE_GIT_REMOTE=\"https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git\"" >> ~/.zprofile
                echo "export HOMEBREW_API_DOMAIN=\"https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api\"" >> ~/.zprofile
                echo "export HOMEBREW_BOTTLE_DOMAIN=\"https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles\"" >> ~/.zprofile
                echo "✅ Tsinghua mirror added to ~/.zprofile"
            fi
        fi
    elif [ "$OS" == "Linux" ]; then
        # Linux 的配置文件
        if [ -f ~/.bash_profile ]; then
            if ! grep -q "HOMEBREW_BREW_GIT_REMOTE" ~/.bash_profile; then
                echo "" >> ~/.bash_profile
                echo "# Homebrew Tsinghua mirror" >> ~/.bash_profile
                echo "export HOMEBREW_BREW_GIT_REMOTE=\"https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git\"" >> ~/.bash_profile
                echo "export HOMEBREW_CORE_GIT_REMOTE=\"https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git\"" >> ~/.bash_profile
                echo "export HOMEBREW_API_DOMAIN=\"https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api\"" >> ~/.bash_profile
                echo "export HOMEBREW_BOTTLE_DOMAIN=\"https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles\"" >> ~/.bash_profile
                echo "✅ Tsinghua mirror added to ~/.bash_profile"
            fi
        fi
    fi
fi

echo ""
echo "✅ Pre-deployment complete!"
