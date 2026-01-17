# Dotter 配置优化总结

## 实现的优化

### 1. 平台检测配置文件
创建了针对不同操作系统的配置模板：

- **macos.toml**: macOS 平台专用配置
- **linux.toml**: Linux 平台专用配置
- **local.example.toml**: 通用模板供参考

使用方法：
```bash
# macOS
cp .dotter/macos.toml .dotter/local.toml

# Linux
cp .dotter/linux.toml .dotter/local.toml
```

### 2. Fish Shell 平台自适应
在 Fish 配置文件中使用 shell 级别的条件判断：

**env.fish**:
```fish
if test (uname) = "Darwin"
    set -gx EDITOR /opt/homebrew/bin/code
else
    set -gx EDITOR vim
end
```

**brew.fish**:
```fish
if test (uname) = "Darwin"
    set -x HOMEBREW_PREFIX /opt/homebrew
    set -x HOMEBREW_CELLAR /opt/homebrew/Cellar
    set -x HOMEBREW_REPOSITORY /opt/homebrew
else
    set -x HOMEBREW_PREFIX $HOME/.linuxbrew
    set -x HOMEBREW_CELLAR $HOME/.linuxbrew/Cellar
    set -x HOMEBREW_REPOSITORY $HOME/.linuxbrew/Homebrew
end
```

### 3. 包选择优化
不同平台可以选择性地启用/禁用包：

**macos.toml** 启用: kitty, zed, bspm, pier, wezterm
**linux.toml** 启用: linuxbrew, wezterm（kitty, zed, bspm, pier 禁用）

### 4. 格式说明
`local.toml` 中的 `[packages]` 部分必须使用数组格式：

```toml
# 正确格式
packages = ["default", "alacritty", "kitty", "helix", "zed"]
```

不能使用键值对格式（会导致 "expected a sequence" 错误）。

## 使用方法

### 在 macOS 上配置
```bash
cd /path/to/dotfiles
cp .dotter/macos.toml .dotter/local.toml
dotter deploy -vf
```

### 在 Linux 上配置
```bash
cd /path/to/dotfiles
cp .dotter/linux.toml .dotter/local.toml
dotter deploy -vf
```

### 自定义配置
复制对应平台的模板后，编辑 `local.toml` 添加或移除包：

```bash
# 编辑 local.toml
vim .dotter/local.toml

# 应用更改
dotter deploy -vf
```

## 优势

1. **单仓库管理**: 所有机器使用同一个 dotfiles 仓库
2. **最小化配置**: 每台机器只需要一个 `local.toml` 文件
3. **自动平台适配**: Fish 脚本自动检测操作系统并设置正确的路径
4. **灵活的包选择**: 可以根据平台或需求选择性地启用工具配置
5. **易于维护**: 添加新机器时只需复制对应的平台配置文件

## 后续改进方向

1. 如果需要更复杂的条件逻辑，可以研究 Dotter 的模板功能
2. 对于用户名不同的场景，可以考虑在 shell 配置中使用 `$USER` 环境变量
3. 可以添加更多平台检测逻辑（如检测特定的 Linux 发行版）
