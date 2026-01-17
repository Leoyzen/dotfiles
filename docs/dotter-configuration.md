# Dotter 配置文件详解

## 配置文件结构

Dotter 使用两个主要配置文件：

- **global.toml** - 全局配置，在所有机器间共享，提交到 git
- **local.toml** - 本地配置，机器特定，应在 `.gitignore` 中

## global.toml 详解

### 基本结构

```toml
# 辅助脚本定义（可选）
[helpers]
script_name = "path/to/helper.{sh,rb,js}"

# 全局设置（可选）
[settings]
default_target_type = "automatic"  # "automatic" | "symbolic" | "template"

# 包定义
[package_name]
depends = ["dep1", "dep2"]  # 包依赖关系

[package_name.files]
# 文件映射（见下文详细说明）

[package_name.variables]
# 包变量（见下文详细说明）
```

### 辅助脚本（Helpers）

定义可在模板中使用的自定义辅助函数：

```toml
[helpers]
# Shell 脚本助手
my_helper = "scripts/my_helper.sh"

# Ruby 脚本助手
ruby_helper = "scripts/ruby_helper.rb"

# JavaScript 脚本助手
js_helper = "scripts/js_helper.js"
```

助手脚本的输出将作为变量注入到模板中。

### 全局设置（Settings）

```toml
[settings]
default_target_type = "automatic"
# 选项：
# - "automatic" - 自动检测（包含 {{ 的为模板，否则为符号链接）
# - "symbolic" - 强制使用符号链接
# - "template"  - 强制使用模板
```

### 包定义

包是配置文件的逻辑分组：

```toml
[vim]
depends = ["shell"]  # 可选：依赖其他包

[vim.files]
.vimrc = "~/.vimrc"
.vim/colors/ = "~/.vim/colors/"

[vim.variables]
editor = "vim"
```

#### 包依赖关系

```toml
# 如果 A 依赖 B，B 依赖 C，选择 A 时会自动启用所有三个
[package_a]
depends = ["package_b"]

[package_b]
depends = ["package_c"]

[package_c]
# 无依赖
```

依赖关系处理：
- 自动传递启用依赖
- 循环依赖会被检测并处理
- 未选择的包及其依赖会被完全忽略

### 文件映射（Files）

#### 简单映射

```toml
[package.files]
".vimrc" = "~/.vimrc"
"config.toml" = "~/.config/app/config.toml"
```

#### 复杂映射（Inline Table）

```toml
[package.files.config.toml]
target = "~/.config/app/config.toml"
type = "symbolic"  # "symbolic" | "template" | 省略（自动）
owner = "username"   # Unix only: 文件所有者
recurse = true      # 目录：是否递归
if = "condition"    # 条件：是否部署
```

#### 类型详解

**1. Automatic（自动）**
```toml
"source" = "target"
# 或省略 type
```
- 检测文件是否包含 `{{`
- 如果包含 → 模板
- 如果不包含 → 符号链接
- 可通过 `[settings]default_target_type` 覆盖

**2. Symbolic（符号链接）**
```toml
"source" = { target = "~/.config/file", type = "symbolic" }
```
- 创建符号链接到源文件
- 源文件变更时，目标自动反映
- 节省磁盘空间

**3. Template（模板）**
```toml
"source" = { target = "~/.config/file", type = "template" }
```
- 使用 Handlebars 模板引擎渲染
- 可以追加或前置内容：
```toml
"source" = {
  target = "~/.config/file",
  type = "template",
  append = "# Custom settings\n",      # 追加到末尾
  prepend = "# Header\n"               # 添加到开头
}
```

#### 目录递归（Recursion）

如果源是目录，会递归处理所有文件：

```toml
[package.files]
"config/" = "~/.config/myapp"
# 等同于：
# "config/file1" = "~/.config/myapp/file1"
# "config/file2" = "~/.config/myapp/file2"
# "config/subdir/file" = "~/.config/myapp/subdir/file"
```

可以单独控制每个目标是否递归：
```toml
"config/" = {
  target = "~/.config/myapp",
  recurse = false  # 禁用递归
}
```

#### 条件部署（Conditional Deployment）

```toml
[ssh.files]
config = {
  target = "~/.ssh/config",
  if = "unix"  # 仅在 Unix 系统部署
}

# 使用 dotter 内置变量
[monitor.files]
battery = {
  target = "~/.config/battery.conf",
  if = "dotter.laptop"  # 条件变量（需要预先定义）
}
```

### 变量定义（Variables）

包变量定义可在模板中使用的值：

```toml
[package.variables]
editor = "vim"
theme = "dark"
brightness = 0.8
```

#### 变量合并规则

当多个包被启用时：
- 第一个包的变量作为基础
- 后续包递归合并（深度合并）
- 非表变量冲突会报错

```toml
[vim.variables]
editor = "vim"
colorscheme = "gruvbox"

[nvim.variables]
editor = "nvim"  # 覆盖 editor
colorscheme = "dracula"  # 覆盖 colorscheme
config.plugins = ["vim-sensible", "vim-fugitive"]  # 合并到 config 表
```

## local.toml 详解

### 基本结构

```toml
# 包含其他配置文件（可选）
includes = ["path/to/included.toml", "another.toml"]

# 要启用的包列表
packages = ["default", "vim", "shell"]

# 本地文件覆盖/添加（可选）
[files]
"local_source" = "~/.config/local_target"

# 本地变量覆盖（可选）
[variables]
local_var = "local_value"
```

### 包选择（Package Selection）

```toml
# 启用单个包
packages = ["default"]

# 启用多个包
packages = ["default", "vim", "tmux"]

# 启用有依赖的包（依赖会自动启用）
packages = ["vim"]
# 如果 vim 依赖 "shell"，shell 也会自动启用
```

### 包含文件（Includes）

包含其他 TOML 配置文件的内容：

```toml
includes = [
  "common/vim.toml",
  "common/shell.toml",
  "machines/laptop.toml"
]
```

被包含的文件应包含完整的包定义：
```toml
# common/vim.toml
[vim.files]
.vimrc = "~/.vimrc"

[vim.variables]
editor = "vim"
```

### 本地覆盖（Local Overrides）

#### 文件覆盖

```toml
[files]
# 添加新的文件映射
"local_config" = "~/.config/local"

# 覆盖 global.toml 中的映射
# 注意：如果文件在已启用的包中已定义，会报错
```

#### 变量覆盖

```toml
[variables]
# 覆盖任何包中定义的变量
editor = "nvim"  # 覆盖 vim.variables.editor
theme = "light"   # 覆盖 default.variables.theme
```

## 路径扩展

### Home 目录（~）

所有路径都会扩展 `~` 为实际 home 目录：

```toml
[files]
"config" = "~/.config/app"
# 等同于：
# "config" = "/home/username/.config/app"  (Linux)
# "config" = "/Users/username/.config/app"  (macOS)
```

### 环境变量

支持环境变量扩展：

```toml
[files]
"config" = "$XDG_CONFIG_HOME/app"
# 或：
"config" = "${XDG_CONFIG_HOME}/app"
```

## 完整示例

### global.toml

```toml
[settings]
default_target_type = "automatic"

[default.files]
".gitconfig" = "~/.gitconfig"
".gitignore_global" = "~/.gitignore"
".tmux.conf" = "~/.tmux.conf"

[default.variables]
git_user = "Your Name"
git_email = "you@example.com"

[vim]
depends = ["shell"]

[vim.files]
".vimrc" = "~/.vimrc"
".vim/colors/gruvbox.vim" = "~/.vim/colors/gruvbox.vim"

[vim.variables]
editor = "vim"
colorscheme = "gruvbox"

[shell.files]
".zshrc" = "~/.zshrc"
".bashrc" = "~/.bashrc"

[shell.variables]
shell_name = "zsh"

[monitor.files]
"battery.conf" = {
  target = "~/.config/battery.conf",
  if = "dotter.laptop"
}
```

### local.toml（笔记本电脑）

```toml
packages = ["default", "vim", "monitor"]

[variables]
dotter.laptop = true
colorscheme = "gruvbox_light"  # 覆盖 vim.variables.colorscheme
```

### local.toml（桌面机）

```toml
packages = ["default", "vim"]

[variables]
dotter.laptop = false
colorscheme = "gruvbox_dark"
```

## 配置验证

### 语法检查

```bash
# TOML 语法检查（需要 toml-cli）
toml validate .dotter/global.toml
toml validate .dotter/local.toml

# 或使用 Python
python -m toml .dotter/global.toml
```

### 部署前测试

```bash
# 查看将要部署的内容
dotter deploy --dry-run

# 查看详细差异
dotter deploy -vv

# 检查配置错误
dotter deploy -v
```

## 常见配置模式

### 简单配置

```toml
[myapp.files]
config = "~/.config/myapp/config"
```

### 条件配置

```toml
[ssh.files]
config = {
  target = "~/.ssh/config",
  if = "dotter.unix"
}

[ssh.variables]
ssh_key_path = "~/.ssh/id_ed25519"
```

### 目录配置

```toml
[config.files]
"nvim/" = "~/.config/nvim"
# 整个目录递归部署
```

### 模板配置

```toml
[editor.files]
".config/vim/init.vim" = {
  target = "~/.config/nvim/init.vim",
  type = "template",
  append = "\n\" Local settings\nset background=dark"
}
```

## 下一步

- [模板系统](./dotter-templates.md) - 学习模板语法和内置变量
- [包系统](./dotter-packages.md) - 理解包的依赖和继承
- [高级特性](./dotter-advanced.md) - 探索 watch 模式和钩子
