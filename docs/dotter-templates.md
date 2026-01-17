# Dotter 模板系统

## 概述

Dotter 使用 [Handlebars](https://handlebarsjs.com/) 模板引擎来渲染配置文件。模板允许你在配置文件中使用变量、条件和循环，实现不同机器间的灵活配置。

## 基本语法

### 变量插值

使用 `{{ variable_name }}` 插入变量值：

```handlebars
# 示例：.vimrc
set editor={{editor}}
set colorscheme={{colorscheme}}
```

如果 `editor` 变量定义为 `"vim"`，输出将是：
```
set editor=vim
set colorscheme=gruvbox
```

### 转义输出

默认情况下，特殊字符会被 HTML 转义（对于配置文件通常不需要）：

```handlebars
{{ variable }}
```

使用三重大括号 `{{{ }}}` 输出原始内容：

```handlebars
{{{ raw_content }}}
```

### 访问嵌套属性

访问表/对象的嵌套属性：

```handlebars
{{ config.editor }}
{{ config.ui.theme }}
```

配置：
```toml
[variables]
config = { editor = "nvim", ui = { theme = "dark" } }
```

## 变量来源

### 1. 包变量（Package Variables）

在 `.dotter/global.toml` 中定义：

```toml
[vim.variables]
editor = "vim"
colorscheme = "gruvbox"
plugin_manager = "vim-plug"
```

在模板中使用：
```handlebars
" Editor: {{editor}}
" Colorscheme: {{colorscheme}}
" Plugin manager: {{plugin_manager}}
```

### 2. 局部变量（Local Variables）

在 `.dotter/local.toml` 中覆盖：

```toml
[variables]
editor = "nvim"  # 覆盖 vim.variables.editor
colorscheme = "dracula"
```

### 3. 辅助脚本（Helpers）

在 `global.toml` 中定义辅助脚本：

```toml
[helpers]
# Shell 脚本（输出到 stdout）
hostname = "scripts/get_hostname.sh"

# Ruby 脚本
ruby_helper = "scripts/ruby_helper.rb"

# JavaScript 脚本
js_helper = "scripts/js_helper.js"
```

`scripts/get_hostname.sh`:
```bash
#!/usr/bin/env bash
hostname
```

在模板中使用：
```handlebars
# This machine: {{hostname}}
# Hostname: {{ruby_helper}}
```

### 4. 内置变量

Dotter 提供以下内置变量：

| 变量名 | 描述 | 示例 |
|--------|------|------|
| `dotter.os` | 操作系统 | "linux", "macos", "windows" |
| `dotter.arch` | 系统架构 | "x86_64", "aarch64" |
| `dotter.home` | Home 目录路径 | "/home/user", "/Users/user" |
| `dotter.hostname` | 主机名 | "laptop-01" |
| `dotter.packages` | 启用的包列表 | ["default", "vim", "shell"] |

使用内置变量：
```handlebars
# OS: {{dotter.os}}
# Arch: {{dotter.arch}}
# Home: {{dotter.home}}
```

## 条件语句

### If/Else

```handlebars
{{#if use_neovim}}
set editor=nvim
{{else}}
set editor=vim
{{/if}}
```

### Unless（反向 If）

```handlebars
{{#unless use_neovim}}
set editor=vim
{{/unless}}
```

### Else If

```handlebars
{{#if editor}}
set editor={{editor}}
{{else if use_nvim}}
set editor=nvim
{{else}}
set editor=vim
{{/if}}
```

## 循环

### Each

遍历数组：

配置：
```toml
[variables]
plugins = ["vim-sensible", "vim-fugitive", "vim-airline"]
```

模板：
```handlebars
" Plugins
{{#each plugins}}
Plug '{{this}}'
{{/each}}
```

输出：
```
" Plugins
Plug 'vim-sensible'
Plug 'vim-fugitive'
Plug 'vim-airline'
```

### 嵌套循环

配置：
```toml
[variables]
plugin_groups = [
  { name = "editor", plugins = ["vim-sensible", "vim-fugitive"] },
  { name = "ui", plugins = ["vim-airline", "gruvbox"] }
]
```

模板：
```handlebars
{{#each plugin_groups}}
" {{name}} plugins:
{{#each plugins}}
Plug '{{this}}'
{{/each}}
{{/each}}
```

### 访问索引

```handlebars
{{#each items}}
Item {{@index}}: {{this}}
{{/each}}
```

辅助变量：
- `@index` - 当前索引（从 0 开始）
- `@first` - 是否第一个
- `@last` - 是否最后一个

## 辅助函数

### 默认值（default）

如果变量为空，使用默认值：

```handlebars
set editor={{default editor "vim"}}
set colorscheme={{default colorscheme "default"}}
```

### 条件默认值（withDefault）

```handlebars
{{#withDefault theme}}
" colorscheme {{this}}
{{/withDefault}}
```

### 比较运算符

```handlebars
{{#if (eq editor "nvim")}}
" Neovim configuration
{{/if}}

{{#if (neq editor "vim")}}
" Not using Vim
{{/if}}

{{#if (gt version 10)}}
" Version greater than 10
{{/if}}

{{#if (lt version 10)}}
" Version less than 10
{{/if}}
```

### 逻辑运算符

```handlebars
{{#if (and is_linux has_gui)}}
" Linux with GUI
{{/if}}

{{#if (or use_nvim use_vim)}}
" Using NeoVim or Vim
{{/if}}

{{#if (not is_server)}}
" Not a server machine
{{/if}}
```

### 字符串操作

```handlebars
{{uppercase hostname}}
{{lowercase theme}}
{{capitalize description}}
{{#capitalize}}
{{description}}
{{/capitalize}}
```

## 自定义辅助函数

创建自定义辅助函数脚本：

### Shell 脚本助手

`scripts/detect_gpu.sh`:
```bash
#!/usr/bin/env bash
# 检测 GPU 类型
if lspci | grep -i nvidia > /dev/null; then
    echo "nvidia"
elif lspci | grep -i amd > /dev/null; then
    echo "amd"
else
    echo "intel"
fi
```

`global.toml`:
```toml
[helpers]
gpu = "scripts/detect_gpu.sh"
```

模板：
```handlebars
# GPU: {{gpu}}
{{#if (eq gpu "nvidia")}}
# NVIDIA graphics
{{/if}}
```

### Ruby 脚本助手

`scripts/config_generator.rb`:
```ruby
#!/usr/bin/env ruby
require 'json'

# 从 STDIN 读取 JSON 格式的变量
input = JSON.parse(STDIN.read)

# 生成配置
config = ""
if input['theme'] == 'dark'
  config += "set background=dark\n"
else
  config += "set background=light\n"
end

# 输出结果
puts config
```

`global.toml`:
```toml
[helpers]
vim_config = "scripts/config_generator.rb"
```

### JavaScript 脚本助手

`scripts/generate_settings.js`:
```javascript
#!/usr/bin/env node
// 从命令行参数读取 JSON
const input = JSON.parse(process.argv[2]);

// 生成设置
const settings = {
  theme: input.theme || 'dark',
  fontSize: input.fontSize || 12
};

// 输出 JSON
console.log(JSON.stringify(settings, null, 2));
```

`global.toml`:
```toml
[helpers]
settings = "scripts/generate_settings.js"
```

## 实用示例

### 示例 1：条件配置

`templates/vimrc`:
```handlebars
" Editor Configuration
" {{editor}} on {{dotter.os}}

set editor={{default editor "vim"}}
set background={{default background "dark"}}

{{#if (eq dotter.os "linux")}}
" Linux-specific settings
set clipboard=unnamedplus
{{/if}}

{{#if (eq dotter.os "macos")}}
" macOS-specific settings
set clipboard=unnamed
{{/if}}
```

### 示例 2：Git 配置

`templates/gitconfig`:
```handlebars
[user]
    name = {{git_name}}
    email = {{git_email}}

{{#if (eq dotter.os "macos")}}
[credential]
    helper = osxkeychain
{{else if (eq dotter.os "linux")}}
[credential]
    helper = cache
{{/if}}

[core]
    editor = {{default editor "vim"}}
```

配置：
```toml
[default.variables]
git_name = "Your Name"
git_email = "you@example.com"
editor = "nvim"
```

### 示例 3：Shell 配置

`templates/zshrc`:
```handlebars
# ~/.zshrc for {{dotter.hostname}}

# Environment variables
export EDITOR={{default editor "vim"}}
export TERM={{default term "xterm-256color"}}

{{#if (eq dotter.os "macos")}}
# macOS Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
{{else if (eq dotter.os "linux")}}
# Linux package manager
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
{{/if}}

# Paths
export PATH="$HOME/.local/bin:$PATH"

{{#each custom_paths}}
export PATH="{{this}}:$PATH"
{{/each}}
```

### 示例 4：Tmux 配置

`templates/tmux.conf`:
```handlebars
# Tmux configuration for {{dotter.hostname}}

# General settings
set -g default-terminal "screen-256color"
set -g history-limit {{default history_limit 10000}}

{{#if (eq dotter.os "macos")}}
# macOS-specific
set -g default-command "reattach-to-user-namespace -l zsh"
{{/if}}

# Key bindings
{{#if use_vim_keybindings}}
setw -g mode-keys vi
{{else}}
setw -g mode-keys emacs
{{/if}}

# Plugins
{{#each plugins}}
run-shell {{this}}
{{/each}}
```

## 调试模板

### 查看渲染结果

使用 `--dry-run` 和 `-v` 标志查看模板渲染结果：

```bash
dotter deploy --dry-run -v
```

### 检查变量

在模板中添加调试输出：

```handlebars
" DEBUG: dotter.os = {{dotter.os}}
" DEBUG: dotter.hostname = {{dotter.hostname}}
" DEBUG: packages = {{dotter.packages}}
" DEBUG: editor = {{default editor "(not set)"}}
```

部署后查看渲染后的文件：
```bash
cat ~/.vimrc
```

### 常见问题

**问题：变量没有展开**

可能原因：
1. 变量未定义（检查 global.toml 或 local.toml）
2. 包未启用（检查 local.toml 的 packages 列表）
3. 变量拼写错误（检查模板中的变量名）

**问题：模板语法错误**

常见错误：
- 忘记关闭 `{{/if}}`
- 括号不匹配
- 使用了不存在的辅助函数

使用 `dotter deploy -v` 查看详细错误信息。

**问题：条件逻辑不工作**

检查：
- 变量值是否正确（添加调试输出）
- 辅助函数语法是否正确
- 比较操作符是否正确（eq, neq, gt, lt 等）

## 最佳实践

### 1. 使用默认值

始终为变量提供合理的默认值：

```handlebars
set editor={{default editor "vim"}}
```

### 2. 条件配置

使用条件逻辑处理平台差异：

```handlebars
{{#if (eq dotter.os "macos")}}
# macOS specific
{{/if}}
```

### 3. 模块化配置

将大配置文件拆分为可重用的部分：

```handlebars
{{#if use_vim}}
source ~/.vimrc.vim
{{/if}}

{{#if use_nvim}}
source ~/.config/nvim/init.vim
{{/if}}
```

### 4. 注释和文档

在模板中添加注释说明：

```handlebars
" Git configuration for {{dotter.hostname}}
" Generated by Dotter
" Template: templates/gitconfig
```

### 5. 避免过度复杂

保持模板简单易读：

```handlebars
# 好的例子 - 清晰简单
set background={{default background "dark"}}

# 不好的例子 - 过度复杂
{{#if (and (or (eq theme "dark") (eq theme "black")) (not (eq background "light")))}}
set background=dark
{{else}}
set background=light
{{/if}}
```

## 下一步

- [包系统](./dotter-packages.md) - 学习如何组织和管理包
- [高级特性](./dotter-advanced.md) - 探索 watch 模式和钩子
- [故障排查](./dotter-troubleshooting.md) - 解决常见问题
