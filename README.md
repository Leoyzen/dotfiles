# Dotfiles

使用 [Dotter](https://github.com/SuperCuber/dotter) 管理的个人配置文件。Dotter 是一个用 Rust 编写的 dotfile 管理器和模板引擎。

## 快速开始

### 安装 Dotter

```bash
# macOS (Homebrew)
brew install dotter

# 或使用 Cargo
cargo install dotter
```

### 部署配置

```bash
# 克隆仓库
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 查看将要部署的变更
dotter --dry-run

# 部署配置
dotter deploy -f
```

## 项目结构

```
.
├── .dotter/              # Dotter 配置
│   ├── global.toml      # 全局配置（所有机器共享）
│   ├── local.toml       # 本地配置（机器特定，在 .gitignore 中）
│   └── pre_deploy.sh    # 部署前钩子
├── config/              # 配置文件目录（按工具分类）
│   ├── editors/         # 编辑器配置
│   │   ├── terminals/   # 终端配置
│   │   ├── helix/       # Helix 配置
│   │   ├── zed/         # Zed 配置
│   │   └── vim/         # Vim 配置
│   ├── shell/           # Shell 配置
│   │   └── fish/        # Fish 配置
│   ├── tools/           # 工具配置
│   │   ├── git/
│   │   ├── tmux.conf
│   │   └── starship.toml
│   ├── linters-formatters/  # 代码检查和格式化工具
│   └── package-managers/    # 包管理器配置
├── scripts/             # 可执行脚本
│   └── entrypoint.sh
├── docs/                # 文档
├── opencode/            # OpenCode 配置
├── Dockerfile           # 容器定义
└── README.md            # 本文件
```

## 配置包说明

### Default 包
基础配置包，包含核心工具配置：
- Fish shell 配置
- Git 配置
- Starship 提示符
- Tmux 配置
- UV 包管理器
- 其他通用工具配置

### Alacritty 包
Alacritty 终端模拟器配置。

### Helix 包
Helix 编辑器配置，包括：
- 主题：gruvbox_material_dark_hard
- 语言服务器：ruff-lsp, ty（用于 Python）
- 自动格式化支持

### Kitty 包
Kitty 终端模拟器配置。

### Linuxbrew 包
Linuxbrew/Linux 上 Homebrew 的 Fish shell 配置。

### Rust 包
Rust 开发工具配置：
- Cargo 配置
- rustfmt 配置
- Rust 相关的 Fish 脚本

### Zed 包
Zed 编辑器配置。

### Conda 包
Conda 包管理器配置。

### TMux/YAPF/Flake8/Cargo/Pip 包
对应的工具配置包（目前为空，根据需要添加）。

## 使用 Dotter

### 基本命令

```bash
# 部署文件（默认命令）
dotter deploy

# 模拟运行（不执行任何操作）
dotter deploy --dry-run

# 详细输出（显示变更）
dotter deploy -v

# 强制覆盖
dotter deploy -f

# 取消部署（删除所有已部署的文件）
dotter undeploy

# 监控模式（自动部署变更）
dotter watch
```

### 配置文件结构

**全局配置** (`.dotter/global.toml`)：
- 定义所有可用的包
- 包含文件映射和变量
- 共享到所有机器

**本地配置** (`.dotter/local.toml`)：
- 选择要激活的包
- 定义机器特定的变量
- **应添加到 `.gitignore`**

### 模板系统

Dotter 支持 Handlebars 模板语法：

```toml
[default.variables]
editor = "vim"
theme = "dark"
```

在配置文件中使用变量：
```handlebars
export EDITOR="{{editor}}"
export THEME="{{theme}}"
```

## 维护指南

### 添加新配置

1. 将配置文件移动到仓库：
   ```bash
   mv ~/.config/newtool newtool
   ```

2. 在 `.dotter/global.toml` 中添加包或文件映射：
   ```toml
   [newtool.files]
   config = "~/.config/newtool/config"
   ```

3. 部署：
   ```bash
   dotter deploy -v
   ```

4. 提交到 Git：
   ```bash
   git add .
   git commit -m "Add newtool configuration"
   git push
   ```

### 更新配置

1. 编辑源文件：
   ```bash
   vim helix/config.toml
   ```

2. 测试变更：
   ```bash
   dotter deploy --dry-run
   ```

3. 应用变更：
   ```bash
   dotter deploy -v
   ```

4. 提交到 Git：
   ```bash
   git commit -am "Update helix configuration"
   git push
   ```

### 新机器部署

```bash
# 1. 克隆仓库
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. 创建机器特定配置
cp .dotter/local.toml.example .dotter/local.toml

# 3. 编辑 local.toml 选择需要的包
vim .dotter/local.toml

# 4. 部署
dotter deploy -f
```

### 多机器配置

使用不同的本地配置文件：

```bash
# 使用 local.toml（默认）
dotter deploy

# 使用 hostname.toml（自动匹配）
dotter deploy -l hostname.toml

# 或创建符号链接
ln -s my-laptop.toml .dotter/local.toml
```

## Dotter 特性

- **模板系统**：支持变量替换、条件判断、循环
- **符号链接**：自动创建符号链接
- **包管理**：支持依赖关系，逻辑分组配置
- **缓存机制**：智能检测变更，避免冗余操作
- **持续监控**：watch 模式自动部署变更
- **多机器支持**：全局配置 + 本地配置分离

## 参考资源

- [Dotter GitHub](https://github.com/SuperCuber/dotter)
- [Dotter Wiki](https://github.com/SuperCuber/dotter/wiki)
- [Handlebars 模板语法](https://handlebarsjs.com/guide/)

## 许可证

本项目配置文件遵循各自工具的许可证。
