# Dotter 最佳实践

## 概述

本章介绍使用 Dotter 的最佳实践和推荐模式，帮助你构建可维护、可扩展的 dotfiles 仓库。

## 项目结构

### 推荐的目录结构

```
~/dotfiles/
├── .dotter/                  # Dotter 配置
│   ├── global.toml           # 全局配置（Git）
│   ├── local.toml            # 本地配置（.gitignore）
│   ├── cache.toml            # 缓存（.gitignore）
│   └── pre_deploy.sh         # 部署前钩子
├── configs/                  # 配置文件分类存放
│   ├── editor/              # 编辑器配置
│   │   ├── vim/
│   │   └── nvim/
│   ├── shell/               # Shell 配置
│   │   ├── zsh/
│   │   ├── fish/
│   │   └── bash/
│   ├── terminal/            # 终端配置
│   │   ├── alacritty/
│   │   └── kitty/
│   └── gui/                 # GUI 应用
│       ├── i3/
│       └── rofi/
├── templates/               # 模板文件（如果需要）
│   ├── vimrc
│   └── gitconfig
├── scripts/                 # 辅助脚本
│   ├── backup.sh
│   └── helpers/
├── docs/                    # 文档
│   ├── dotter-*.md
│   └── README.md
├── .gitignore               # Git 忽略文件
├── .gitattributes           # Git 属性
└── README.md               # 项目说明
```

### 文件组织原则

1. **按功能分类**：将相关配置放在一起
2. **使用子目录**：避免根目录混乱
3. **清晰的命名**：使用描述性的文件名
4. **模块化**：每个工具独立目录

## Git 管理

### .gitignore 配置

```gitignore
# Dotter
.dotter/local.toml
.dotter/cache.toml
.dotter/cache/

# 编辑器临时文件
*.swp
*.swo
*~
.DS_Store
*.bak

# IDE 配置
.vscode/
.idea/

# 系统文件
Thumbs.db
desktop.ini

# 敏感信息
*.secret
*.key
.ssh/
credentials/
```

### .gitattributes 配置

```gitattributes
# 文本文件
*.sh text eol=lf
*.fish text eol=lf
*.zsh text eol=lf

# 模板文件
*.template text eol=lf

# 配置文件
*.toml text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.json text eol=lf

# 二进制文件（如果有）
*.png binary
*.jpg binary
```

### 提交策略

**频繁提交，小步前进**：
```bash
# 每完成一个配置就提交
git add .dotter/global.toml
git commit -m "Add vim package definition"

git add configs/editor/vim/
git commit -m "Add vim configuration"

git add templates/
git commit -m "Add template files"
```

**描述性提交信息**：
```
feat: Add neovim configuration
fix: Correct zsh template syntax
docs: Update dotter documentation
refactor: Reorganize config structure
```

### 分支策略

**主分支**：
- `main` 或 `master` - 稳定版本
- 只合并经过测试的配置

**开发分支**：
- `dev` - 开发中
- 新配置在此测试

**特性分支**：
- `feature/add-editor`
- `bugfix/shell-config`

```bash
# 创建特性分支
git checkout -b feature/add-editor

# 完成后合并到 dev
git checkout dev
git merge feature/add-editor

# 测试后合并到 main
git checkout main
git merge dev
```

## 配置管理

### 全局配置（global.toml）

**清晰组织**：
```toml
# ============================================
# 全局设置
# ============================================
[settings]
default_target_type = "automatic"
watch_interval = 1000

# ============================================
# 辅助脚本
# ============================================
[helpers]
hostname = "scripts/get_hostname.sh"
detect_gpu = "scripts/detect_gpu.sh"

# ============================================
# 基础包（所有机器）
# ============================================
[default]
[default.files]
".gitconfig" = "~/.gitconfig"
".tmux.conf" = "~/.tmux.conf"

[default.variables]
git_name = "Your Name"
git_email = "you@example.com"

# ============================================
# Shell 配置
# ============================================
[shell]
[shell.files]
".zshrc" = "~/.zshrc"
".config/fish/config.fish" = "~/.config/fish/config.fish"

# ============================================
# 编辑器配置
# ============================================
[vim]
depends = ["shell"]
[vim.files]
".vimrc" = "~/.vimrc"

[nvim]
depends = ["shell"]
[nvim.files]
".config/nvim/init.vim" = "~/.config/nvim/init.vim"

# ============================================
# GUI 配置
# ============================================
[gui]
depends = ["terminal", "window-manager"]
```

### 本地配置（local.toml）

**示例：笔记本电脑**：
```toml
# 笔记本电脑配置

# 包含共享配置
includes = [
  "common/default.toml",
  "common/shell.toml",
  "common/editor.toml"
]

# 启用的包
[packages]
default = true
shell = true
editor = true
gui = true
monitor = true  # 电池监控

# 本地变量
[variables]
laptop = true
battery_enabled = true
touchpad_enabled = true
theme = "gruvbox_light"
```

**示例：桌面机**：
```toml
# 桌面机配置

includes = [
  "common/default.toml",
  "common/shell.toml",
  "common/editor.toml"
]

[packages]
default = true
shell = true
editor = true
gui = true

[variables]
laptop = false
desktop = true
theme = "gruvbox_dark"
```

**示例：服务器**：
```toml
# 服务器配置

includes = [
  "common/default.toml",
  "common/shell.toml"
]

[packages]
default = true
shell = true
development = true

# 不启用 GUI
[variables]
server = true
minimal = true
```

## 模板最佳实践

### 1. 使用默认值

```handlebars
# 好的例子 - 有默认值
set editor={{default editor "vim"}}
set colorscheme={{default colorscheme "default"}}

# 不好的例子 - 无默认值
set editor={{editor}}  # 如果 editor 未定义，会出错
```

### 2. 保持简单

```handlebars
# 好的例子 - 清晰简单
{{#if (eq dotter.os "macos")}}
# macOS specific
set clipboard=unnamed
{{/if}}

# 不好的例子 - 过度复杂
{{#if (or (and (eq dotter.os "macos") (eq dotter.arch "x86_64")) (and (eq dotter.os "linux") (eq dotter.arch "aarch64")))}}
# Complex logic
{{/if}}
```

### 3. 文档化模板

```handlebars
" ============================================
"  Vim Configuration
"  Generated by Dotter
"  Template: templates/vimrc
"  Last updated: 2024-01-15
" ============================================

" Variables
"   - editor: {{editor}}
"   - colorscheme: {{colorscheme}}
" ============================================

set editor={{default editor "vim"}}
set colorscheme={{default colorscheme "default"}}
```

### 4. 模块化模板

```handlebars
# 主配置文件
if has('nvim')
  source ~/.config/nvim/init.vim
else
  source ~/.vimrc
endif

# 特定功能配置
{{#if use_plugins}}
source ~/.vimrc.plugins
{{/if}}

# 本地配置
source ~/.vimrc.local
```

## 包管理最佳实践

### 1. 明确包职责

```toml
# 好的例子 - 职责明确
[vim]
# 仅包含 Vim 相关配置

[shell]
# 仅包含 Shell 相关配置

# 不好的例子 - 职责混杂
[vim]
# Vim 配置
# Shell 配置 ❌
# Git 配置 ❌
```

### 2. 最小依赖

```toml
# 好的例子 - 最小依赖
[gui]
depends = ["terminal"]  # 只依赖必要的包

# 不好的例子 - 过度依赖
[gui]
depends = ["terminal", "shell", "editor", "git", "development"]  # 依赖太多
```

### 3. 命名规范

```toml
# 使用小写，下划线分隔
[vim_plugin_manager]           # 好
[vim-plugin-manager]           # 好
[pluginManager]                # 避免（大写）
[pluginmanager]                # 避免（不易读）
```

### 4. 包分组

```toml
# 基础组
[default]
[shell]
[git]

# 编辑器组
[vim]
[nvim]
[editor]

# 终端组
[alacritty]
[kitty]
[terminal]

# GUI 组
[i3]
[rofi]
[gui]

# 工具组
[docker]
[kubectl]
[tools]
```

## 部署流程

### 1. 测试先行

```bash
# 始终先 dry-run
dotter deploy --dry-run

# 检查输出，确认正确后再部署
dotter deploy -v
```

### 2. 渐进式部署

```bash
# 先部署基础配置
dotter deploy -p default

# 验证正常后再部署其他
dotter deploy -p shell
dotter deploy -p editor
```

### 3. 使用 watch 模式

```bash
# 开发时使用 watch 模式
dotter watch &

# 修改配置
vim configs/editor/vim/.vimrc

# watch 自动部署
# [Watch] Detected change in configs/editor/vim/.vimrc
# [Watch] Deploying...
# [Watch] Done
```

### 4. 备份现有配置

```bash
# 部署前备份
cp -r ~/.config ~/dotfiles.backup/$(date +%Y%m%d_%H%M%S)

# 或使用 hook
[pre_deploy]
scripts = ["scripts/backup.sh"]
```

## 安全实践

### 1. 保护敏感信息

```handlebars
# 不好的例子 - 直接包含密码
[default.variables]
api_key = "my-secret-key"

# 好的例子 - 使用环境变量
[default.variables]
api_key = "{{env API_KEY}}"

# 或使用占位符
api_key = "{{default api_key 'YOUR_API_KEY_HERE'}}"
```

### 2. 使用 .gitignore

```gitignore
# 敏感信息
*.secret
*.key
.ssh/
credentials/
.env
.local
```

### 3. 使用模板分离敏感信息

```handlebars
# 公共配置
[user]
    name = {{git_name}}
    email = {{git_email}}

# 私有配置（本地）
{{#if (contains git_email "company.com")}}
[company]
    jira_token = {{company_jira_token}}
{{/if}}
```

### 4. 加密敏感文件

```bash
# 使用 git-crypt
brew install git-crypt
git-crypt init

# 加密文件
echo "*.secret filter=git-crypt diff=git-crypt" >> .gitattributes
git-crypt add-gpg-user <email>
```

## 性能优化

### 1. 使用符号链接

对于不包含模板的配置，使用符号链接（默认）：

```toml
[files]
".vimrc" = "~/.vimrc"
# 自动识别为符号链接（因为没有 {{）
```

### 2. 减少文件数量

```bash
# 只部署需要的包
dotter deploy -p vim
```

### 3. 排除不必要的文件

```toml
[settings]
watch_ignore = [
  "node_modules",
  "*.log",
  ".git",
  "dist/",
  "build/"
]
```

### 4. 调整 watch 间隔

```toml
[settings]
# 开发：快速响应
watch_interval = 500

# 生产：节省资源
watch_interval = 5000
```

## 文档管理

### 1. README.md

```markdown
# Dotfiles

使用 Dotter 管理的个人配置文件。

## 快速开始

\`\`\`bash
git clone https://github.com/username/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
dotter deploy --dry-run
dotter deploy -f
\`\`\`

## 包说明

- default - 基础配置
- shell - Shell 配置
- vim - Vim/Neovim 配置
- gui - GUI 应用配置

## 文档

详见 [docs/](docs/) 目录。

## 许可证

MIT
```

### 2. 变更日志

```markdown
# Changelog

## [Unreleased]

### Added
- Neovim 配置
- Fish shell 配置

### Changed
- 更新 Vim 插件列表
- 重构配置目录结构

### Fixed
- 修复 Zsh 模板语法错误

## [1.0.0] - 2024-01-15

### Added
- 初始版本
- Vim 配置
- Shell 配置
```

### 3. 文档结构

```
docs/
├── dotter-basics.md           # 基础概念
├── dotter-configuration.md    # 配置详解
├── dotter-templates.md       # 模板系统
├── dotter-packages.md        # 包系统
├── dotter-advanced.md        # 高级特性
├── dotter-troubleshooting.md # 故障排查
└── dotter-best-practices.md  # 最佳实践（本文档）
```

## 团队协作

### 1. 代码审查

```bash
# 创建 Pull Request
git checkout -b feature/new-config
# 修改配置
git add .
git commit -m "Add new tool configuration"
git push origin feature/new-config
# 在 GitHub 上创建 PR
```

### 2. 冲突解决

```bash
# 拉取最新变更
git pull origin main

# 解决冲突
git add .
git commit -m "Resolve conflicts"
git push origin feature-branch
```

### 3. 配置规范

团队应制定统一的配置规范：

```toml
# 规范 1: 统一包命名
[tool_name]  # 小写，下划线

# 规范 2: 统一变量命名
tool_name_version = "1.0.0"

# 规范 3: 统一文件组织
configs/tool_name/config.yml
```

## 维护建议

### 1. 定期更新

```bash
# 每月检查更新
brew update
brew upgrade

# 更新配置
cd ~/dotfiles
git pull
dotter deploy -f
```

### 2. 清理配置

```bash
# 移除不用的包
rm -rf configs/unused-tool/
vim .dotter/global.toml  # 移除包定义

# 清理缓存
rm .dotter/cache.toml
dotter deploy -f
```

### 3. 版本标记

```bash
# 发布新版本
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### 4. 备份策略

```bash
# 自动备份
# 添加到 crontab
0 0 * * * cd ~/dotfiles && git push
0 0 * * 0 cp -r ~/.config ~/backup/config-$(date +\%Y\%m\%d)
```

## 常见模式

### 模式 1: 多编辑器配置

```toml
[editor.variables]
vim_enabled = true
nvim_enabled = true
default_editor = "nvim"
```

模板：
```handlebars
{{#if vim_enabled}}
if has('nvim')
  finish
endif
{{/if}}

{{#if nvim_enabled}}
if !has('nvim')
  finish
endif
{{/if}}
```

### 模式 2: 跨平台配置

```toml
[platform.variables]
os_specific_config = {
  linux = "linux.conf",
  macos = "macos.conf",
  windows = "windows.conf"
}
```

模板：
```handlebars
{{#if (eq dotter.os "linux")}}
source ~/.config/{{platform.os_specific_config.linux}}
{{else if (eq dotter.os "macos")}}
source ~/.config/{{platform.os_specific_config.macos}}
{{/if}}
```

### 模式 3: 条件功能

```toml
[features.variables]
use_plugins = true
use_lsp = true
use_completion = true
```

模板：
```handlebars
{{#if use_plugins}}
call plug#begin('~/.vim/plugged')
{{/if}}

{{#if use_lsp}}
" LSP configuration
{{/if}}

{{#if use_completion}}
" Completion configuration
{{/if}}
```

## 总结

### 关键原则

1. **简单优先**：保持配置简单易懂
2. **文档完善**：清晰记录每个配置的作用
3. **版本控制**：使用 Git 追踪所有变更
4. **测试驱动**：部署前 always dry-run
5. **渐进改进**：小步前进，频繁提交
6. **安全第一**：保护敏感信息
7. **性能意识**：避免不必要的部署
8. **团队协作**：建立统一的规范

### 快速检查清单

部署前检查：
- [ ] 运行 `dotter deploy --dry-run`
- [ ] 检查输出是否正确
- [ ] 备份重要配置
- [ ] 在测试环境验证

提交前检查：
- [ ] 配置测试正常
- [ ] 提交信息清晰
- [ ] 敏感信息已排除
- [ ] 文档已更新

## 参考资源

- [Dotter GitHub](https://github.com/SuperCuber/dotter)
- [Dotter Wiki](https://github.com/SuperCuber/dotter/wiki)
- [Handlebars 文档](https://handlebarsjs.com/)
- [Git 工作流程](https://www.atlassian.com/git/tutorials/comparing-workflows)

---

**最后更新**: 2024-01-15
