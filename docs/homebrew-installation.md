# Homebrew 安装和配置

## 使用方法

`pre_deploy.sh` 脚本在 `dotter deploy` 时自动执行，完成以下功能：

1. **检测 Homebrew/Linuxbrew 是否已安装**
2. **如果未安装，从清华镜像自动安装**
3. **配置清华镜像源**

## 自动安装流程

### macOS
```bash
dotter deploy
```

脚本会：
1. 检测是否已安装 `/opt/homebrew/bin/brew`
2. 如果未安装，从清华镜像克隆并运行安装脚本
3. 检查 Xcode Command Line Tools（macOS 需要）
4. 配置镜像源到 `~/.zprofile`

### Linux
```bash
dotter deploy
```

脚本会：
1. 检测是否已安装 `~/.linuxbrew/bin/brew`
2. 如果未安装，从清华镜像克隆并运行安装脚本
3. 安装到用户主目录 `~/.linuxbrew/`
4. 配置镜像源到 `~/.bash_profile`

## 清华镜像配置

安装后，以下环境变量会被添加到你的 shell 配置：

```bash
# Homebrew 清华镜像
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
```

## 手动安装（如果自动安装失败）

### macOS
```bash
/bin/bash -c "$(curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install/raw/master/install.sh)"
```

### Linux
```bash
# 设置镜像环境变量
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

# 从镜像安装
/bin/bash -c "$(curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install/raw/master/install.sh)"
```

## 完整部署流程

### 首次部署（全新环境）
```bash
# 1. 部署 dotfiles（会自动检查和安装 Homebrew）
dotter deploy -v

# 2. 安装常用包
./.dotter/post_deploy_simple.sh

# 3. 重新加载 shell
source ~/.zprofile  # macOS
# 或
source ~/.bash_profile  # Linux
```

### 日常更新
```bash
# 更新 dotfiles
dotter deploy -v

# 更新 Homebrew 和包
brew update
brew upgrade
```

## 故障排除

### 安装失败
如果 Homebrew 安装失败：

1. **检查网络连接**：确保能访问 mirrors.tuna.tsinghua.edu.cn
2. **检查必要工具**：
   - macOS: 确保已安装 Xcode Command Line Tools (`xcode-select --install`)
   - Linux: 确保已安装 git 和 curl
3. **检查磁盘空间**：至少需要 500MB 可用空间
4. **检查权限**：确保有写入目标目录的权限

### 镜像切换

如果想切换回官方源：
```bash
# 编辑 shell 配置文件，删除或注释掉镜像相关的 export
vim ~/.zprofile  # macOS
vim ~/.bash_profile  # Linux

# 重新加载 shell
source ~/.zprofile  # macOS
source ~/.bash_profile  # Linux

# 更新 Homebrew
brew update
```

### 多用户支持

如果有多个用户使用同一机器，每个用户需要：
1. 运行 `dotter deploy` 部署配置
2. Homebrew 会安装到各自用户的主目录
3. 各自独立管理包

更多信息：
- [清华 Homebrew 镜像](https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/)
- [Homebrew 官方文档](https://docs.brew.sh/)
