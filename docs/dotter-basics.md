# Dotter 基础指南

## 什么是 Dotter？

Dotter 是一个用 Rust 编写的 dotfile 管理器和模板引擎。Dotfiles 通常是指 home 目录下以 `.` 开头的配置文件。

### 为什么需要 Dotter？

传统的 dotfile 管理方式（手动创建符号链接）存在以下问题：
- **难以追踪**：当有大量 dotfiles 时，很难记住它们来自哪里
- **部署繁琐**：在新机器上需要手动创建每一个符号链接
- **无法处理差异**：无法处理不同机器之间的配置差异（例如笔记本需要电池指示器，桌面机不需要）

Dotter 通过提供灵活的配置和自动化的模板/符号链接解决了这些问题。

## 安装

### macOS (Homebrew)
```bash
brew install dotter
```

### Arch Linux (AUR)
```bash
# 预编译版本
yay -S dotter-rs-bin

# 从源码构建
yay -S dotter-rs

# 最新 git 版本
yay -S dotter-rs-git
```

### Windows (Scoop)
```bash
scoop install dotter
```

### 其他方式

从 [GitHub Releases](https://github.com/SuperCuber/dotter/releases) 下载二进制文件并放入 `$PATH`，或使用 cargo 安装：

```bash
cargo install dotter
```

## 快速开始

### 1. 初始化仓库

```bash
# 创建 dotfiles 仓库
mkdir ~/dotfiles
cd ~/dotfiles

# 初始化 git 仓库（可选）
git init
git add .
git commit -m "Initial dotfiles"

# 使用 dotter 初始化
dotter init
```

这会创建 `.dotter/global.toml` 和 `.dotter/local.toml` 配置文件。

### 2. 配置文件

**global.toml** - 全局配置，所有机器共享
```toml
[default.files]
".vimrc" = "~/.vimrc"

[default.variables]
editor = "vim"
```

**local.toml** - 本地配置，机器特定（应添加到 .gitignore）
```toml
[packages]
default = true
```

### 3. 部署配置

```bash
# 预览将要部署的变更（推荐先运行这个）
dotter deploy --dry-run

# 部署配置文件
dotter deploy

# 详细模式（显示差异）
dotter deploy -v

# 强制覆盖
dotter deploy -f
```

## 基本概念

### 包（Packages）

包是逻辑分组的相关配置文件集合。例如：
- `default` - 基础配置
- `vim` - Vim 编辑器配置
- `shell` - Shell 相关配置
- `gui` - GUI 应用配置

### 符号链接 vs 模板

Dotter 支持两种文件部署方式：

**符号链接（Symlink）**
- 直接链接到仓库中的文件
- 文件改变时，链接的目标文件也会改变
- 适合不包含模板变量的配置文件
- 节省磁盘空间（不复制文件）

**模板（Template）**
- 使用 Handlebars 模板引擎渲染文件
- 可以使用变量和条件逻辑
- 文件内容会根据变量值动态生成
- 适合需要在不同机器间有差异的配置文件

### 缓存机制

Dotter 维护一个缓存文件 `.dotter/cache.toml`，记录：
- 哪些文件已被部署
- 部署到了哪里
- 文件类型（符号链接或模板）

缓存让 Dotter 能够：
- 智能更新（只修改已变更的文件）
- 正确删除（undeploy 时只删除部署过的文件）
- 检测类型变更（从符号链接改为模板）

## 工作流程

典型的 dotfiles 管理工作流程：

```bash
# 1. 添加新配置到仓库
mv ~/.config/newtool ~/dotfiles/newtool

# 2. 更新 global.toml
vim .dotter/global.toml
# 添加:
# [newtool.files]
# config = "~/.config/newtool/config"

# 3. 测试部署
dotter deploy --dry-run

# 4. 应用更改
dotter deploy -v

# 5. 提交到 git
git add .
git commit -m "Add newtool configuration"
git push
```

## 多机器管理

Dotter 天生支持多机器配置：

```bash
# 笔记本电脑
cat ~/.dotfiles/laptop.toml
[packages]
default = true
vim = true
battery-monitor = true  # 笔记本专用

# 台式机
cat ~/.dotfiles/desktop.toml
[packages]
default = true
vim = true
gpu-drivers = true    # 台式机专用
```

使用方法：
```bash
# dotter 会自动查找 local.toml 或 <hostname>.toml
dotter deploy

# 或手动指定配置
dotter -l laptop.toml deploy
```

## 下一步

- [配置文件详解](./dotter-configuration.md) - 了解 global.toml 和 local.toml 的详细语法
- [模板系统](./dotter-templates.md) - 学习如何使用变量和条件逻辑
- [包系统](./dotter-packages.md) - 理解包的依赖和继承
- [高级特性](./dotter-advanced.md) - 探索 watch 模式、钩子等高级功能
- [故障排查](./dotter-troubleshooting.md) - 解决常见问题
- [最佳实践](./dotter-best-practices.md) - 学习推荐的配置方式

## 参考资源

- [Dotter GitHub](https://github.com/SuperCuber/dotter)
- [Dotter Wiki](https://github.com/SuperCuber/dotter/wiki)
- [Handlebars 文档](https://handlebarsjs.com/guide/)
