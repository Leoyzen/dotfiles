# Dotter 包系统

## 概述

Dotter 的包系统允许你将配置文件组织成逻辑分组，便于管理和选择性地部署。包支持依赖关系，可以自动处理包之间的相互依赖。

## 包的基本概念

### 什么是包？

包是相关配置文件的集合，通常对应一个特定的工具、功能或用途。例如：

- **vim** - Vim/Neovim 编辑器的所有配置
- **shell** - Shell 相关配置（zsh, fish, bash）
- **gui** - GUI 应用配置（i3, alacritty, rofi）
- **development** - 开发工具配置（git, docker, kubectl）
- **monitor** - 系统监控配置（battery, temperature）

### 包的好处

- **逻辑分组** - 相关配置集中管理
- **选择性部署** - 只启用需要的包
- **依赖管理** - 自动处理包之间的依赖
- **清晰结构** - 易于理解和维护

## 定义包

### 基本包定义

在 `.dotter/global.toml` 中定义包：

```toml
[vim]
[vim.files]
".vimrc" = "~/.vimrc"
".vim/colors/" = "~/.vim/colors/"

[vim.variables]
editor = "vim"
colorscheme = "gruvbox"
```

### 带依赖的包

使用 `depends` 字段定义依赖关系：

```toml
[vim]
depends = ["shell"]

[vim.files]
".vimrc" = "~/.vimrc"

[shell]
[shell.files]
".zshrc" = "~/.zshrc"
".bashrc" = "~/.bashrc"
```

当启用 `vim` 包时，`shell` 包会自动启用。

## 启用包

### 在 local.toml 中启用

```toml
# 启用单个包
[packages]
default = true

# 启用多个包
[packages]
default = true
vim = true
shell = true
gui = true

# 或者使用数组格式（不推荐，因为有 bug）
# [packages]
# default = true
# vim = true
# shell = true
```

**重要提示**：使用数组格式（`packages = ["default", "vim"]`）时可能有 bug，建议使用键值对格式。

### 命令行指定包

```bash
# 启用特定包
dotter deploy -p vim

# 启用多个包
dotter deploy -p vim -p shell -p gui

# 从文件读取包列表
dotter deploy --packages-from-file packages.txt
```

`packages.txt`:
```
vim
shell
gui
```

## 依赖关系

### 基本依赖

```toml
[gui]
depends = ["terminal"]

[terminal]
depends = ["shell"]

[shell]
[shell.files]
".zshrc" = "~/.zshrc"
```

启用 `gui` 时，会自动启用 `terminal` 和 `shell`。

### 依赖解析规则

1. **传递性**：依赖的依赖也会被启用
   ```
   A 依赖 B，B 依赖 C
   启用 A → 启用 B → 启用 C
   ```

2. **单向性**：依赖关系是单向的
   - `gui` 依赖 `terminal` 不意味着 `terminal` 依赖 `gui`

3. **唯一性**：每个包只启用一次
   - 即使被多个包依赖，也只启用一次

4. **非循环性**：循环依赖会被处理
   - A → B → C → A 会被正确处理

### 复杂依赖示例

```toml
[desktop]
depends = ["gui", "development"]

[gui]
depends = ["terminal", "window-manager"]

[development]
depends = ["shell", "git", "editor"]

[terminal]
depends = ["shell"]

[window-manager]
[git]
[editor]
[shell]
```

启用 `desktop` 时，会启用：
```
desktop
├── gui
│   ├── terminal
│   │   └── shell
│   └── window-manager
└── development
    ├── shell (已启用，不会重复)
    ├── git
    └── editor
```

最终启用的包：
- desktop
- gui
- terminal
- shell
- window-manager
- development
- git
- editor

## 变量合并

### 变量合并规则

当多个包被启用时，变量按以下规则合并：

1. **基础变量**：第一个启用的包的变量作为基础
2. **递归合并**：后续包的变量递归合并（深度合并）
3. **表合并**：表类型变量合并
4. **标量冲突**：非表变量冲突时报错

### 表变量合并

```toml
[vim.variables]
editor = "vim"
config = {
  colorscheme = "gruvbox",
  font = "monospace"
}

[nvim.variables]
editor = "nvim"
config = {
  colorscheme = "dracula",  # 覆盖
  fontsize = 12            # 新增
}
```

如果同时启用 `vim` 和 `nvim`：
```toml
editor = "nvim"  # 冲突，报错
config = {
  colorscheme = "dracula",
  font = "monospace",
  fontsize = 12
}
```

### 解决标量变量冲突

使用条件逻辑：

```toml
# 方式 1: 使用不同变量名
[vim.variables]
vim_editor = "vim"

[nvim.variables]
nvim_editor = "nvim"

# 在模板中
# {{#if vim_editor}}
# set editor={{vim_editor}}
# {{/if}}
# {{#if nvim_editor}}
# set editor={{nvim_editor}}
# {{/if}}
```

```toml
# 方式 2: 使用 local.toml 覆盖
[vim.variables]
editor = "vim"

[nvim.variables]
# 不定义 editor

# local.toml
[variables]
editor = "nvim"
```

## 常见包模式

### 1. 基础包（default）

包含所有机器都需要的配置：

```toml
[default.files]
".gitconfig" = "~/.gitconfig"
".tmux.conf" = "~/.tmux.conf"
".config/starship.toml" = "~/.config/starship.toml"

[default.variables]
git_name = "Your Name"
git_email = "you@example.com"
```

### 2. 编辑器包（editor）

编辑器配置：

```toml
[vim.files]
".vimrc" = "~/.vimrc"
".vimrc.bundles" = "~/.vimrc.bundles"

[vim.variables]
editor = "vim"
plugin_manager = "vim-plug"

[nvim.files]
".config/nvim/init.vim" = "~/.config/nvim/init.vim"

[nvim.variables]
editor = "nvim"
plugin_manager = "paq-nvim"
```

### 3. Shell 包（shell）

Shell 配置：

```toml
[shell.files]
".zshrc" = "~/.zshrc"
".bashrc" = "~/.bashrc"
".config/fish/config.fish" = "~/.config/fish/config.fish"

[shell.variables]
default_shell = "zsh"
```

### 4. GUI 包（gui）

GUI 应用配置：

```toml
[gui]
depends = ["terminal", "window-manager"]

[terminal.files]
".config/alacritty/alacritty.yml" = "~/.config/alacritty/alacritty.yml"

[window-manager.files]
".config/i3/config" = "~/.config/i3/config"
".config/i3status/config" = "~/.config/i3status/config"
```

### 5. 工具包（tools）

开发工具配置：

```toml
[git.files]
".gitconfig" = "~/.gitconfig"
".gitignore_global" = "~/.gitignore"

[docker.files]
".docker/config.json" = "~/.docker/config.json"

[kubectl.files]
".kube/config" = "~/.kube/config"
```

### 6. 监控包（monitor）

系统监控配置：

```toml
[monitor.files]
".config/battery/battery.conf" = "~/.config/battery/battery.conf"
".config/cpu/cpu.conf" = "~/.config/cpu/cpu.conf"

[monitor.variables]
battery_enabled = true
cpu_enabled = true
```

### 7. 语言包（languages）

编程语言工具配置：

```toml
[rust.files]
".cargo/config.toml" = "~/.cargo/config.toml"
".rustfmt.toml" = "~/.rustfmt.toml"

[python.files]
".pylintrc" = "~/.pylintrc"
".flake8" = "~/.flake8"

[node.files]
".npmrc" = "~/.npmrc"
".yarnrc.yml" = "~/.yarnrc.yml"
```

## 包组织建议

### 层次化组织

```
default (基础)
├── shell (Shell 基础)
├── git (Git 基础)
└── editor (编辑器基础)
    ├── vim
    └── nvim

desktop (桌面环境)
├── gui
│   ├── terminal
│   └── window-manager
├── development
│   └── editor
└── monitor

server (服务器)
├── shell
├── development
└── tools
```

### 按功能分组

```
shell/          # Shell 相关
├── zsh
├── fish
└── bash

editor/         # 编辑器相关
├── vim
├── nvim
└── vscode

terminal/       # 终端相关
├── alacritty
└── kitty

development/    # 开发相关
├── git
├── docker
└── kubectl
```

### 按使用场景

```
laptop/         # 笔记本电脑
├── power_management
├── battery_monitor
└── touchpad_config

desktop/        # 台式机
├── gpu_drivers
├── monitor_config
└── keyboard_layout

server/         # 服务器
├── minimal_shell
├── essential_tools
└── monitoring
```

## 实际示例

### 示例 1：笔记本电脑配置

`local.toml`:
```toml
[packages]
default = true
gui = true
editor = true
development = true
monitor = true

[variables]
laptop = true
battery_enabled = true
touchpad_enabled = true
```

启用的包：
- default
- shell (default 依赖)
- git (default 依赖)
- editor
- gui
  - terminal
  - window-manager
- development
- monitor

### 示例 2：服务器配置

`local.toml`:
```toml
[packages]
default = true
development = true
monitor = false  # 不启用 GUI 监控

[variables]
laptop = false
server = true
minimal = true
```

### 示例 3：临时环境

`local.toml`:
```toml
[packages]
shell = true
editor = true  # 只部署编辑器和 shell
```

## 包管理最佳实践

### 1. 最小依赖

避免不必要的依赖关系：

```toml
# 好的例子 - 最小依赖
[gui]
depends = ["terminal"]

# 不好的例子 - 过度依赖
[gui]
depends = ["terminal", "shell", "editor", "development"]
```

### 2. 明确职责

每个包应该有明确的职责：

```toml
# 好的例子 - 职责明确
[vim]
# 仅包含 Vim 相关配置

[shell]
# 仅包含 Shell 相关配置

# 不好的例子 - 职责混杂
[vim]
# 包含 Vim 配置
# 还包含 Shell 配置 ❌
```

### 3. 可重用变量

定义可在多个包中使用的变量：

```toml
[common.variables]
theme = "gruvbox"
font = "monospace 12"

[vim.variables]
# 继承 common.variables
colorscheme = "gruvbox"

[terminal.variables]
# 继承 common.variables
font_name = "monospace"
font_size = 12
```

### 4. 条件启用

使用条件逻辑处理包差异：

```toml
[vim.files]
".vimrc" = {
  target = "~/.vimrc",
  if = "dotter.laptop"  # 仅在笔记本电脑上启用
}
```

### 5. 文档化包

在 global.toml 中添加注释说明包的用途：

```toml
# Base configuration for all systems
[default]
[default.files]
".gitconfig" = "~/.gitconfig"

# Editor configuration (Vim/Neovim)
[vim]
[vim.files]
".vimrc" = "~/.vimrc"

# GUI applications (terminal, window-manager, etc.)
[gui]
depends = ["terminal"]
```

## 调试包

### 查看启用的包

```bash
# 使用 -v 标志查看启用的包
dotter deploy -v
```

输出示例：
```
Packages: default, shell, vim, terminal
```

### 检查依赖关系

使用 `dotter deploy --dry-run -v` 查看包依赖解析：

```bash
dotter deploy --dry-run -v
```

### 验证变量合并

在模板中添加调试输出：

```handlebars
" DEBUG: packages = {{dotter.packages}}
" DEBUG: editor = {{editor}}
" DEBUG: colorscheme = {{colorscheme}}
```

### 常见问题

**问题：包没有启用**
- 检查 `local.toml` 中的 `packages` 列表
- 确认包名拼写正确
- 检查依赖链是否正确

**问题：变量冲突**
- 使用不同的变量名
- 使用 `local.toml` 覆盖
- 检查是否有不必要的变量定义

**问题：依赖未自动启用**
- 检查 `depends` 字段是否正确
- 确认依赖的包已定义
- 查看详细输出 `dotter deploy -v`

## 下一步

- [模板系统](./dotter-templates.md) - 学习如何在包中使用模板
- [高级特性](./dotter-advanced.md) - 探索 watch 模式和钩子
- [最佳实践](./dotter-best-practices.md) - 了解推荐的配置方式
