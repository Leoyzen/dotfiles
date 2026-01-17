# Dotter 故障排查

## 概述

本章介绍使用 Dotter 时可能遇到的常见问题及其解决方法。

## 常见错误

### 错误 1: "No such file or directory"

**错误信息**：
```
Error: No such file or directory (os error 2)
```

**原因**：
- 源文件不存在
- 路径配置错误

**解决方法**：
```bash
# 检查源文件是否存在
ls -la ~/dotfiles/.vimrc

# 检查 global.toml 中的路径
cat .dotter/global.toml | grep .vimrc

# 使用相对路径或绝对路径
# 错误：
[vim.files]
".vimrc" = "~/.vimrc"  # 如果 .vimrc 在仓库根目录
# 正确：
[vim.files]
".vimrc" = "~/.vimrc"  # 确保 .vimrc 在根目录
```

### 错误 2: "Permission denied"

**错误信息**：
```
Error: Permission denied (os error 13)
```

**原因**：
- 没有目标目录的写入权限
- 尝试写入系统目录

**解决方法**：
```bash
# 检查目标目录权限
ls -ld ~/.config/

# 确保有写权限
mkdir -p ~/.config/

# 如果需要系统目录权限
sudo dotter deploy  # 不推荐
```

### 错误 3: "Template syntax error"

**错误信息**：
```
Error: Template syntax error: Unclosed block
```

**原因**：
- 模板语法错误
- 忘记关闭 `{{/if}}` 或 `{{/each}}`

**解决方法**：
```bash
# 使用 dry-run 查看详细错误
dotter deploy --dry-run -v

# 检查模板文件
cat templates/vimrc

# 验证括号配对
# {{#if condition}}
#   ...
# {{/if}}  # 确保关闭
```

### 错误 4: "Variable not defined"

**错误信息**：
```
Error: Variable 'editor' is not defined
```

**原因**：
- 变量未在包或 local.toml 中定义
- 变量名拼写错误

**解决方法**：
```bash
# 检查变量定义
cat .dotter/global.toml | grep variables
cat .dotter/local.toml | grep variables

# 使用默认值
# {{default editor "vim"}}

# 定义变量
[variables]
editor = "vim"
```

### 错误 5: "Package not found"

**错误信息**：
```
Error: Package 'nonexistent' not found
```

**原因**：
- 包名拼写错误
- 包未在 global.toml 中定义

**解决方法**：
```bash
# 查看所有可用的包
cat .dotter/global.toml | grep "^\["

# 检查包名拼写
# 正确：
[packages]
vim = true
```

### 错误 6: "Circular dependency detected"

**错误信息**：
```
Error: Circular dependency detected: vim -> shell -> vim
```

**原因**：
- 包之间存在循环依赖

**解决方法**：
```toml
# 错误：循环依赖
[vim]
depends = ["shell"]

[shell]
depends = ["vim"]

# 正确：移除循环依赖
[vim]
depends = ["shell"]

[shell]
# 移除对 vim 的依赖
```

### 错误 7: "Cache file corrupted"

**错误信息**：
```
Error: Failed to parse cache file
```

**原因**：
- 缓存文件损坏
- 手动编辑了缓存文件

**解决方法**：
```bash
# 删除缓存文件
rm .dotter/cache.toml

# 强制重新部署
dotter deploy -f
```

## 部署问题

### 问题：文件没有更新

**症状**：
- 修改了源文件，但目标文件未更新
- 执行 `dotter deploy` 没有效果

**原因**：
- 缓存问题
- 文件类型检测错误
- 包未启用

**解决方法**：
```bash
# 清除缓存
rm .dotter/cache.toml

# 强制重新部署
dotter deploy -f

# 检查包是否启用
dotter deploy -v | grep Packages

# 检查文件类型
# 确保模板文件包含 {{}} 才会被识别为模板
```

### 问题：符号链接未创建

**症状**：
- 文件被复制而不是创建符号链接

**原因**：
- 文件包含 `{{` 被识别为模板
- 文件类型显式配置为 template

**解决方法**：
```toml
# 显式指定为符号链接
[files]
"config" = {
  target = "~/.config/file",
  type = "symbolic"  # 强制符号链接
}

# 或确保文件不包含 {{
# 从模板文件中移除所有 {{ 变量
```

### 问题：模板变量未展开

**症状**：
- `{{variable}}` 出现在输出中
- 变量没有被替换

**原因**：
- 文件类型被识别为符号链接
- 变量未定义
- 模板语法错误

**解决方法**：
```bash
# 确保文件类型为 template
cat .dotter/cache.toml  # 查看文件类型

# 强制模板类型
[files]
"config" = {
  target = "~/.config/file",
  type = "template"
}

# 检查变量定义
dotter deploy -v  # 查看启用的包和变量
```

## Watch 模式问题

### 问题：Watch 模式不响应变更

**症状**：
- 修改文件后 watch 模式没有反应
- 没有看到 "Detected change" 消息

**原因**：
- watch 间隔太长
- 文件被忽略
- watch 进程未运行

**解决方法**：
```bash
# 检查 watch 进程是否运行
ps aux | grep dotter

# 停止并重新启动
pkill dotter
dotter watch

# 检查 watch 配置
cat .dotter/global.toml | grep watch

# 减少检查间隔
[settings]
watch_interval = 500  # 毫秒
```

### 问题：Watch 模式频繁重新部署

**症状**：
- Watch 模式不断重新部署
- 编辑器临时文件触发部署

**原因**：
- 编辑器创建临时文件
- 文件被忽略列表排除

**解决方法**：
```toml
# 添加编辑器临时文件到忽略列表
[settings]
watch_ignore = [
  "*.swp",     # Vim 交换文件
  "*.swo",     # Vim 备份文件
  "*~",         # 备份文件
  ".DS_Store",  # macOS
  "node_modules"
]
```

## 权限问题

### 问题：无法写入系统目录

**症状**：
```
Error: Permission denied (os error 13)
```

**原因**：
- 尝试写入需要 root 权限的目录

**解决方法**：
```bash
# 方式 1: 避免使用系统目录
# 将配置部署到用户目录
[files]
"config" = "~/.config/app/config"
# 而不是：
# "config" = "/etc/app/config"

# 方式 2: 使用 sudo（不推荐）
sudo dotter deploy

# 方式 3: 手动创建符号链接（推荐）
sudo ln -s ~/dotfiles/system/config /etc/app/config
```

## 性能问题

### 问题：部署太慢

**原因**：
- 部署了太多文件
- 使用了过多的模板
- 文件系统性能问题

**解决方法**：
```bash
# 只部署需要的包
dotter deploy -p vim

# 使用符号链接代替模板
# 检查文件是否真的需要模板功能

# 优化模板
# 减少复杂的条件逻辑

# 使用 SSD 或更快的存储
```

### 问题：Watch 模式占用太多 CPU

**原因**：
- 检查间隔太短
- 文件数量太多

**解决方法**：
```toml
# 增加检查间隔
[settings]
watch_interval = 5000  # 5 秒
```

```bash
# 减少监控的文件数量
# 将不常修改的配置移到单独的仓库
```

## 调试技巧

### 1. 使用 Dry-run

```bash
# 预览将要部署的内容
dotter deploy --dry-run
```

### 2. 详细输出

```bash
# 查看详细的部署信息
dotter deploy -v

# 更详细的输出（包括 diff）
dotter deploy -vv
```

### 3. 检查缓存

```bash
# 查看缓存内容
cat .dotter/cache.toml
```

### 4. 测试单个文件

```bash
# 手动测试模板渲染
cat templates/vimrc | handlebars -v editor=vim

# 检查文件映射
dotter deploy --dry-run -v | grep vimrc
```

### 5. 验证配置

```bash
# 验证 TOML 语法
toml validate .dotter/global.toml
toml validate .dotter/local.toml

# 或使用 Python
python -m toml .dotter/global.toml
```

### 6. 启用调试日志

```bash
# 设置环境变量
export RUST_LOG=debug
dotter deploy -v
```

## 日志分析

### 理解输出

```bash
$ dotter deploy -v
# 以下输出解释：

# 部署的包
Packages: default, vim, shell

# 正在部署的文件
[Deploying] ~/.vimrc
  Type: symbolic
  Source: .vimrc
  Target: ~/.vimrc

[Deploying] ~/.config/nvim/init.vim
  Type: template
  Source: nvim.template
  Target: ~/.config/nvim/init.vim

# 跳过的文件（未变更）
[Skipped] ~/.gitconfig
  Reason: No changes

# 部署完成
[Done] Deployed 2 files, skipped 1 file
```

### 常见输出解释

- **[Deploying]**: 正在部署文件
- **[Skipped]**: 文件未变更，跳过
- **[Deleting]**: 正在删除文件（undeploy）
- **[Warning]**: 警告信息，不影响部署
- **[Error]**: 错误信息，停止部署

## 获取帮助

### 内置帮助

```bash
# 查看帮助
dotter --help

# 查看子命令帮助
dotter deploy --help
dotter watch --help
```

### GitHub Issues

如果问题无法解决，请：
1. 在 [Dotter GitHub Issues](https://github.com/SuperCuber/dotter/issues) 搜索类似问题
2. 创建新 Issue 时，提供以下信息：
   - Dotter 版本 (`dotter --version`)
   - 操作系统和架构
   - 完整的错误信息
   - `dotter deploy -v` 的输出
   - 相关的配置文件内容

### 社区资源

- [Dotter Wiki](https://github.com/SuperCuber/dotter/wiki)
- [Discussions](https://github.com/SuperCuber/dotter/discussions)
- [Reddit r/dotfiles](https://reddit.com/r/dotfiles)

## 预防性措施

### 1. 备份

```bash
# 部署前备份现有配置
cp -r ~/.config ~/dotfiles.backup

# 或使用 pre-deploy hook
[pre_deploy]
scripts = ["scripts/backup.sh"]
```

### 2. 测试配置

```bash
# 始终先使用 dry-run
dotter deploy --dry-run

# 在测试机器上测试
# 不要直接在生产环境测试
```

### 3. 版本控制

```bash
# 提交前测试
dotter deploy --dry-run
git add .
git commit -m "Test configuration"
```

### 4. 渐进式部署

```bash
# 先部署一个包
dotter deploy -p vim

# 验证正常后再部署其他
dotter deploy -p shell
```

## 常见问题 FAQ

### Q: Dotter 会删除我的现有配置吗？

A: 不会。Dotter 不会覆盖现有的配置，除非：
- 文件是符号链接（直接更新链接）
- 明确指定了 `-f` 标志

### Q: 如何回滚到之前的配置？

A: 使用 Git 版本控制：
```bash
git log
git checkout <commit> .
dotter deploy -f
```

### Q: 可以在多个仓库中使用 Dotter 吗？

A: 可以，每个仓库都是独立的。

### Q: Dotter 会跟踪配置文件的内容吗？

A: 不会。Dotter 只跟踪：
- 文件映射关系
- 文件类型
- 部署状态

内容由 Git 管理。

### Q: 如何在多个机器间同步配置？

A: 使用 Git：
```bash
# 在机器 A 上提交
git add .
git commit -m "Update config"
git push

# 在机器 B 上拉取
git pull
dotter deploy -f
```

## 下一步

- [最佳实践](./dotter-best-practices.md) - 学习推荐的配置方式
