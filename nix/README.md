# Nix Home Manager 配置

这是 `dotfiles` 仓库的 Nix Home Manager 原生配置版本。

## 📁 文件结构

```
nix/
├── flake.nix                  # Flake 配置（入口）
├── README.md                  # 本文档
└── home-manager/
    ├── home.nix              # 主配置入口
    └── modules/
        ├── shell.nix         # Shell 配置（Fish, Starship）
        ├── editors.nix       # 编辑器配置（Helix, Zed, Vim）
        ├── tools.nix         # 工具配置（Git, Tmux）
        └── dev-tools.nix     # 开发工具（Python, Rust）
```

## 🚀 快速开始

### 1. 安装 Nix

```bash
# 使用官方安装器
curl --proto '=https' --tlsv1.2 -sSf https://nixos.org/nix/install | sh

# 或者使用 Determinate Nix Installer（推荐）
curl --proto '=https' --tlsv1.2 -sSf https://install.determinate.systems/nix | sh -s -- install
```

### 2. 启用 Flakes

```bash
# 创建或编辑 nix.conf
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
```

### 3. 应用配置

#### 方式一：使用 Flake（推荐）

```bash
# 进入 nix 目录
cd ~/dotfiles/nix

# 应用配置（自动检测架构）
home-manager switch --flake .#leoyzen

# 或者指定特定配置
home-manager switch --flake .#leoyzen@macos-arm     # Apple Silicon
home-manager switch --flake .#leoyzen@macos-intel   # Intel Mac
home-manager switch --flake .#leoyzen@linux-x86     # Linux x86_64
home-manager switch --flake .#leoyzen@linux-arm     # Linux ARM
```

#### 方式二：使用传统方式

```bash
cd ~/dotfiles/nix/home-manager
home-manager switch -f ./home.nix
```

## 🔧 常用命令

```bash
# 更新所有包
home-manager switch --flake .#leoyzen --upgrade

# 以递归方式更新所有输入
nix flake update

# 查看可用的 generation
home-manager generations

# 回滚到上一个 generation
home-manager switch --flake .#leoyzen --rollback

# 回滚到特定 generation
home-manager switch --generation 42

# 清理旧的 generation（保留最近 5 个）
home-manager generations | tail -n +6 | xargs -n 1 home-manager remove-generations

# 进入开发 shell
nix develop

# 格式化 Nix 代码
nix fmt
```

## 📚 配置说明

### 模块化设计

配置分为四个主要模块：

| 模块 | 文件 | 说明 |
|------|------|------|
| Shell | `modules/shell.nix` | Fish shell, Starship prompt, fzf, zoxide |
| 编辑器 | `modules/editors.nix` | Helix (Nix 原生), Zed (JSON 配置), Vim |
| 工具 | `modules/tools.nix` | Git, Tmux |
| 开发工具 | `modules/dev-tools.nix` | UV, Ruff, Rust 工具链 |

### 配置转换示例

#### Helix (TOML → Nix)

**原始 TOML (config/editors/helix/config.toml):**
```toml
theme = "gruvbox-material-dark-hard"

[editor]
auto-save = true
auto-format = true
line-number = "relative"
```

**Nix 原生 (home-manager/modules/editors.nix):**
```nix
programs.helix = {
  enable = true;
  settings = {
    theme = "gruvbox-material-dark-hard";
    editor = {
      auto-save = true;
      auto-format = true;
      line-number = "relative";
    };
  };
};
```

#### 类型安全优势

Nix 配置提供：
- **自动补全**: 编辑器知道你有哪些选项可用
- **类型检查**: 配置错误在构建时被发现
- **文档**: `man home-configuration.nix`

### 自定义配置

#### 修改 Git 配置

编辑 `home-manager/modules/tools.nix`:
```nix
programs.git = {
  userName = "你的名字";
  userEmail = "your@email.com";
  # ...
};
```

#### 添加新包

编辑 `home-manager/home.nix`:
```nix
home.packages = with pkgs; [
  # 添加你的包
  neofetch
  htop
  # ...
];
```

#### 添加自定义文件

```nix
# 方式1: 直接写入
home.file.".config/app/config.json".text = ''
  {
    "key": "value"
  }
'';

# 方式2: 引用外部文件
home.file.".config/app/config.json".source = ../../config/app/config.json;

# 方式3: XDG 配置目录 (推荐)
xdg.configFile."app/config.json".source = ../../config/app/config.json;
```

## 🔄 与 Dotter 的关系

| | Dotter | Nix Home Manager |
|--|--------|------------------|
| 配置方式 | 符号链接+模板 | Nix 表达式（原生） |
| 回滚 | 手动 | 自动 generation |
| 类型安全 | 无 | 有 |
| 包管理 | Homebrew | Nix |
| 多平台 | 支持 | 原生支持 |

### 迁移建议

1. **学习阶段**: 保持 Dotter 工作流，并行使用 Nix
2. **熟悉后**: 将常用配置转为 Nix 原生
3. **完全迁移** (可选): 移除 Dotter 依赖

## 🐛 故障排除

### Flake 锁定文件问题

```bash
# 更新 flake.lock
nix flake update

# 或删除后重新生成
rm flake.lock
nix flake lock
```

### 包不可用

如果某个包在 nixpkgs 中找不到：

```nix
# 使用 unstable 包
home.packages = [
  pkgs.unstable.zed-editor
];

# 或使用 overlay
nixpkgs.overlays = [
  (final: prev: {
    zed-editor = prev.zed-editor.overrideAttrs (old: {
      # 自定义...
    });
  })
];
```

### macOS 特定问题

#### 允许 Nix 守护进程
```bash
sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

#### Xcode 命令行工具
```bash
xcode-select --install
```

## 📖 学习资源

- [Home Manager 选项查询](https://nix-community.github.io/home-manager/options.xhtml)
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Nix 入门教程
- [Nixpkgs 手册](https://nixos.org/manual/nixpkgs/stable/)
- [Home Manager 手册](https://nix-community.github.io/home-manager/)

## 💡 高级技巧

### 使用秘密管理

```nix
# 使用 sops-nix 管理加密文件
programs.git.extraConfig = {
  user.signingkey = config.sops.secrets.gpg_key.path;
};
```

### 条件配置

```nix
# 根据平台不同配置
programs.git.extraConfig = lib.mkMerge [
  (lib.mkIf pkgs.stdenv.isDarwin {
    credential.helper = "osxkeychain";
  })
  (lib.mkIf pkgs.stdenv.isLinux {
    credential.helper = "libsecret";
  })
];

# 或根据主机名
config = lib.mkIf (config.networking.hostName == "work-laptop") {
  # 工作特定配置
};
```

### 使用 Home Manager 作为 NixOS/Darwin 模块

```nix
# flake.nix - 系统配置中导入
darwinConfigurations."hostname" = nix-darwin.lib.darwinSystem {
  modules = [
    home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.leoyzen = import ./home-manager/home.nix;
    }
  ];
};
```

---

> 💡 **提示**: 如果你对本配置有任何问题或改进建议，欢迎提交 PR！