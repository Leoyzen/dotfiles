# Homebrew 包配置文件

## 使用说明

本目录包含两个部署后脚本：
- **post_deploy.sh**: 交互式安装，支持自定义选项
- **post_deploy_simple.sh**: 非交互式，自动安装核心包

## 使用方法

### 交互式安装（推荐用于首次设置）
```bash
cd /path/to/dotfiles
dotter deploy -v
.dotter/post_deploy.sh
```

### 快速安装（推荐用于日常使用）
```bash
cd /path/to/dotfiles
dotter deploy -v
.dotter/post_deploy_simple.sh
```

## 包列表

### macOS 核心包
- **Shell**: fish, starship
- **Terminal**: tmux
- **CLI 工具**: bat, eza, fd, fzf, ripgrep, tree
- **系统监控**: bottom, procs, gdu
- **环境管理**: direnv
- **Git 工具**: gh, git-delta
- **Python**: uv

### macOS Cask 包（GUI 应用）
- **终端**: alacritty, kitty, wezterm
- **编辑器**: visual-studio-code
- **其他**: iterm2, rectangle, obsidian

### Linux 核心包
- **Shell**: fish, starship
- **Terminal**: tmux
- **CLI 工具**: bat, eza, fd, fzf, ripgrep, tree
- **系统监控**: bottom, procs, gdu
- **环境管理**: direnv
- **Git 工具**: gh, git-delta
- **Python**: uv
- **编辑器**: neovim

### 开发工具包（可选）
- **构建工具**: cmake
- **语言**: rustup, go, node, python

## 自定义包列表

编辑 `.dotter/post_deploy.sh` 中的包数组来添加或移除包：

```bash
# 示例：添加新的 macOS 包
macos_core+=("your-new-package")

# 示例：添加新的 Linux 包
linux_core+=("your-new-package")
```

## 平台检测

脚本自动检测操作系统：
- `Darwin` → macOS
- `Linux` → Linux

根据操作系统自动：
1. 设置正确的 Homebrew/Linuxbrew 路径
2. 选择对应的包列表
3. 安装平台特定的包

## 故障排除

### Homebrew 未安装
如果脚本提示 Homebrew 未找到，请先安装：

**macOS**:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Linux**:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 权限问题
如果脚本无法执行：
```bash
chmod +x .dotter/post_deploy.sh
```

### 包安装失败
如果某些包安装失败，检查：
1. 网络连接
2. Homebrew 更新：`brew update`
3. 包名是否正确：`brew search package-name`
