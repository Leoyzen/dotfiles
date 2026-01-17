# Dotter 文档

Dotter 是一个用 Rust 编写的 dotfile 管理器和模板引擎。

## 官方文档

详细文档请参考官方 Wiki：
- **Wiki 首页**: https://github.com/SuperCuber/dotter/wiki
- **GitHub 仓库**: https://github.com/SuperCuber/dotter

Wiki 包含以下内容：
- 安装指南
- 配置说明
- 模板系统
- 最佳实践
- 故障排除
- 包管理
- 高级用法

## 快速参考

### 安装

```bash
# macOS (Homebrew)
brew install dotter

# Cargo
cargo install dotter
```

### 基本命令

```bash
# 部署配置（默认命令）
dotter deploy

# 模拟运行
dotter --dry-run

# 详细输出
dotter -v

# 强制覆盖
dotter -f

# 取消部署
dotter undeploy

# 监控模式
dotter watch
```

### 配置文件

- `.dotter/global.toml` - 全局配置（所有机器共享）
- `.dotter/local.toml` - 本地配置（机器特定）
- `.dotter/pre_deploy.sh` - 部署前钩子
- `.dotter/post_deploy.sh` - 部署后钩子

### 模板语法

支持 Handlebars 模板：

```toml
[default.variables]
editor = "vim"
theme = "dark"
```

使用变量：
```handlebars
export EDITOR="{{editor}}"
export THEME="{{theme}}"
```
