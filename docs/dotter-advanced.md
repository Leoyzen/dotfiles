# Dotter 高级特性

## 概述

本章介绍 Dotter 的高级特性，包括 watch 模式、钩子、特殊文件类型、缓存管理等高级功能。

## Watch 模式

### 基本用法

Watch 模式自动监控配置文件变更并重新部署：

```bash
# 启动 watch 模式
dotter watch
```

当配置文件（如 `.vimrc`）被修改时，Dotter 会：
1. 检测到变更
2. 自动重新部署
3. 更新目标文件

### Watch 配置

在 `global.toml` 中配置 watch 行为：

```toml
[settings]
# 检查间隔（毫秒），默认 1000
watch_interval = 1000

# 忽略的文件模式
watch_ignore = [
  "*.swp",
  "*.swo",
  "*~"
]
```

### Watch 模式示例

```bash
# Terminal 1: 启动 watch 模式
cd ~/dotfiles
dotter watch

# Terminal 2: 编辑配置文件
vim helix/config.toml

# Terminal 1: 自动检测变更并重新部署
# [Watch] Detected change in helix/config.toml
# [Watch] Deploying...
# [Watch] Done
```

### Watch 最佳实践

1. **排除临时文件**：
   ```toml
   [settings]
   watch_ignore = [
     "*.swp",     # Vim 交换文件
     "*.swo",     # Vim 备份
     "*~",         # 备份文件
     ".DS_Store",  # macOS 文件
     "node_modules"
   ]
   ```

2. **调整检查间隔**：
   ```toml
   [settings]
   # 快速响应（用于开发）
   watch_interval = 500

   # 节省资源（生产环境）
   watch_interval = 5000
   ```

3. **结合版本控制**：
   ```bash
   # 启动 watch
   dotter watch &
   WATCH_PID=$!

   # 修改配置后提交
   git add .
   git commit -m "Update config"

   # 停止 watch
   kill $WATCH_PID
   ```

## 钩子（Hooks）

### Pre-deploy Hook

在部署前执行的脚本。

**在 global.toml 中配置**：
```toml
[pre_deploy]
# 执行顺序
scripts = [
  "scripts/backup.sh",
  "scripts/check_conflicts.sh"
]

# 如果脚本失败，是否停止部署
fail_fast = true  # 默认：true
```

**示例：备份现有配置**
`scripts/backup.sh`:
```bash
#!/usr/bin/env bash
# 备份现有配置到 ~/dotfiles.backup/$(date +%Y%m%d_%H%M%S)

BACKUP_DIR="$HOME/dotfiles.backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 备份关键文件
for file in ".vimrc" ".zshrc" ".gitconfig"; do
  if [ -f "$HOME/$file" ]; then
    cp "$HOME/$file" "$BACKUP_DIR/"
    echo "Backed up $file"
  fi
done

echo "Backup created at $BACKUP_DIR"
```

### Post-deploy Hook

部署后执行的脚本（暂不支持，计划中）。

### Hook 脚本规范

1. **可执行权限**：
   ```bash
   chmod +x scripts/backup.sh
   ```

2. **错误处理**：
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail  # 严格模式
   ```

3. **返回码**：
   - 0: 成功，继续部署
   - 非 0: 失败，停止部署（如果 fail_fast=true）

## 特殊文件类型

### 目标类型控制

除了自动检测，可以显式指定文件类型：

```toml
[package.files]
# 符号链接（默认，如果没有 {{）
".vimrc" = { target = "~/.vimrc", type = "symbolic" }

# 模板
"config.template" = { target = "~/.config/app/config", type = "template" }
```

### 复杂映射选项

```toml
[package.files]
# 完整选项
"source" = {
  target = "~/.config/app/config",
  type = "symbolic",          # 文件类型
  owner = "username",         # 文件所有者（Unix only）
  group = "groupname",        # 文件组（Unix only）
  mode = "0644",              # 文件权限（Unix only）
  recurse = true,             # 递归处理目录
  if = "dotter.laptop",       # 条件部署
  append = "\n# Custom",      # 追加内容（模板）
  prepend = "# Header\n"      # 前置内容（模板）
}
```

### Unix 权限管理

```toml
[package.files]
"scripts/myapp.sh" = {
  target = "/usr/local/bin/myapp.sh",
  type = "symbolic",
  mode = "0755"  # 可执行
}

"config/app.conf" = {
  target = "~/.config/app/app.conf",
  type = "symbolic",
  mode = "0644"  # 只读
}
```

**注意**：
- 需要适当的权限才能修改所有者/组
- 权限格式使用八进制（前导 0）

### 文件所有者和组

```toml
[package.files]
"config/sudoers" = {
  target = "/etc/sudoers.d/dotfiles",
  type = "template",
  owner = "root",
  group = "wheel",
  mode = "0440"
}
```

**警告**：修改系统文件需要 sudo 权限，不推荐用于 dotfiles 管理。

## 缓存管理

### 缓存文件位置

`.dotter/cache.toml` - 记录部署状态

### 缓存结构

```toml
[files]
~/.vimrc = { type = "symbolic", source = ".vimrc" }
~/.zshrc = { type = "template", source = "zshrc.template" }

[packages]
default = true
vim = true
```

### 清除缓存

```bash
# 删除缓存文件
rm .dotter/cache.toml

# 强制重新部署（不使用缓存）
dotter deploy -f
```

### 缓存的作用

缓存让 Dotter 能够：
1. **智能更新**：只修改已变更的文件
2. **正确删除**：undeploy 时只删除部署过的文件
3. **检测类型变更**：从符号链接改为模板
4. **避免重复**：不会重复部署相同的文件

## 文件删除（Undeploy）

### 基本用法

```bash
# 删除所有已部署的文件
dotter undeploy
```

### Dry-run

```bash
# 预览将要删除的文件
dotter undeploy --dry-run
```

### 详细输出

```bash
# 显示删除详情
dotter undeploy -v
```

### 注意事项

⚠️ **警告**：
- 只删除通过 Dotter 部署的文件
- 不删除 Dotter 未跟踪的文件
- 不删除目录（除非是空的）
- 备份重要文件前执行 undeploy

## 包含文件（Includes）

### 在 local.toml 中包含其他配置

```toml
includes = [
  "common/vim.toml",
  "common/shell.toml",
  "machines/laptop.toml"
]
```

### 被包含文件的格式

`common/vim.toml`:
```toml
[vim.files]
".vimrc" = "~/.vimrc"
".vim/colors/" = "~/.vim/colors/"

[vim.variables]
editor = "vim"
colorscheme = "gruvbox"
```

### 包含文件的优势

1. **模块化**：按功能组织配置
2. **复用**：多个机器共享配置
3. **清晰**：易于理解和维护

### 示例结构

```
.dotter/
├── global.toml          # 全局包定义
├── local.toml           # 本地包选择
├── common/              # 共享配置
│   ├── vim.toml
│   ├── shell.toml
│   └── git.toml
└── machines/            # 机器特定配置
    ├── laptop.toml
    ├── desktop.toml
    └── server.toml
```

`local.toml` (laptop):
```toml
includes = [
  "common/vim.toml",
  "common/shell.toml",
  "machines/laptop.toml"
]
```

## 高级用例

### 用例 1：条件部署

```toml
[battery_monitor.files]
"battery.conf" = {
  target = "~/.config/battery/battery.conf",
  if = "dotter.laptop"  # 仅在笔记本上部署
}

[battery_monitor.variables]
battery_threshold = 20
```

### 用例 2：动态文件名

使用模板动态生成目标路径：

```toml
[editor.files]
"config" = {
  target = "~/.config/{{editor}}/init.vim",
  type = "template"
}
```

如果 `editor = "nvim"`，目标为 `~/.config/nvim/init.vim`

### 用例 3：多环境配置

```toml
[default.files]
"gitconfig" = {
  target = "~/.gitconfig",
  type = "template"
}

[default.variables]
git_name = "Your Name"
git_email = "personal@example.com"
```

`work.local.toml`:
```toml
[variables]
git_email = "work@company.com"
```

模板 `.gitconfig.template`:
```handlebars
[user]
    name = {{git_name}}
    email = {{git_email}}

{{#if (contains git_email "company.com")}}
[company]
    jira_token = "xxx"
{{/if}}
```

### 用例 4：临时配置

使用 `if` 条件部署临时配置：

```toml
[debug.files]
".config/debug.conf" = {
  target = "~/.config/debug.conf",
  if = "dotter.debug"
}
```

在需要时启用：
```bash
# 启用调试配置
export DOTTER_DEBUG=true
dotter deploy

# 或在 local.toml 中
[variables]
dotter.debug = true
```

### 用例 5：版本切换

管理不同版本的配置：

```toml
[nvim.variables]
nvim_version = "0.9"

[nvim.files]
"nvim-{{nvim_version}}/" = {
  target = "~/.config/nvim/",
  type = "template"
}
```

根据版本部署不同的配置文件。

## 性能优化

### 减少部署文件数

```bash
# 只部署特定包
dotter deploy -p vim
```

### 使用符号链接

对于不包含模板的文件，使用符号链接（默认行为）：

```toml
[files]
"config.yml" = "~/.config/app/config.yml"
# 自动检测为符号链接（因为没有 {{）
```

### 排除不必要的文件

```toml
[settings]
watch_ignore = [
  "node_modules",
  "*.log",
  ".git"
]
```

### 调整 watch 间隔

```toml
[settings]
# 降低检查频率（节省 CPU）
watch_interval = 5000
```

## 故障排查

### Watch 模式不工作

```bash
# 检查是否正确启动
dotter watch

# 检查文件权限
ls -la ~/dotfiles

# 手动触发部署测试
dotter deploy -v
```

### Hook 脚本失败

```bash
# 手动测试脚本
./scripts/backup.sh
echo $?

# 检查脚本权限
ls -l scripts/backup.sh

# 查看详细错误
dotter deploy -v
```

### 缓存问题

```bash
# 删除缓存
rm .dotter/cache.toml

# 强制重新部署
dotter deploy -f

# 查看缓存内容
cat .dotter/cache.toml
```

## 下一步

- [故障排查](./dotter-troubleshooting.md) - 解决常见问题
- [最佳实践](./dotter-best-practices.md) - 学习推荐的配置方式
