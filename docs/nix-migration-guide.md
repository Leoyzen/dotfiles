# Dotter 到 Nix Home Manager 迁移指南

本指南帮助你从 Dotter 迁移到 Nix Home Manager，展示两种配置方式的对比。

## 🎯 核心概念对比

| 概念 | Dotter | Nix Home Manager |
|------|--------|------------------|
| **配置语言** | TOML + 模板 | Nix 表达式 |
| **部署方式** | 符号链接 | Nix Store + 硬链接 |
| **版本控制** | Git | Git + Nix Flake Lock |
| **回滚** | 手动恢复 | `home-manager switch --rollback` |
| **类型检查** | 无 | 原生支持 |

---

## 📦 配置语法对比

### 1. 基础文件映射

**Dotter (`.dotter/global.toml`):**
```toml
[default.files]
"config/editors/helix/config.toml" = "~/.config/helix/config.toml"
"config/tools/starship.toml" = "~/.config/starship.toml"
```

**Nix Home Manager:**
```nix
# 方式1: 引用外部文件
home.file.".config/helix/config.toml".source = 
  ../../config/editors/helix/config.toml;

# 方式2: Nix 原生配置 (推荐)
programs.helix = {
  enable = true;
  settings = {
    theme = "gruvbox-material-dark-hard";
  };
};
```

---

### 2. 变量和模板

**Dotter:**
```toml
[default.variables]
git_user_name = "Leoyzen"
git_user_email = "leoyzen@gmail.com"

[default.files]
"config/tools/git" = { target = "~/.gitconfig", type = "template" }
```

```ini
# config/tools/git (模板)
[user]
    name = {{git_user_name}}
    email = {{git_user_email}}
```

**Nix:**
```nix
# 方式1: 直接在 Nix 中定义
programs.git = {
  userName = "Leoyzen";
  userEmail = "leoyzen@gmail.com";
};

# 方式2: 让配置文件可配置
{ config, lib, ... }:
let
  cfg = {
    username = "Leoyzen";
    email = "leoyzen@gmail.com";
  };
in
{
  programs.git = {
    userName = cfg.username;
    userEmail = cfg.email;
  };
}
```

---

### 3. 包安装

**Dotter:**
- 通过 `pre_deploy.sh` / `post_deploy.sh` 调用 Homebrew
- 或使用外部包管理器

```bash
# .dotter/post_deploy.sh
brew install helix tmux starship
```

**Nix:**
```nix
home.packages = with pkgs; [
  helix
  tmux
  starship
  rustup
  uv
];
```

---

### 4. Shell 配置

**Dotter:**
```toml
[default.files]
"config/shell/fish/conf.d" = "~/.config/fish/conf.d"
"config/shell/fish/fish_plugins" = "~/.config/fish/fish_plugins"
```

**Nix:**
```nix
programs.fish = {
  enable = true;
  
  # 环境变量
  shellInit = ''
    set -gx EDITOR hx
    set -gx FZF_DEFAULT_COMMAND "fd --type file"
  '';
  
  # 函数
  functions = {
    ll = "ls -la $argv";
  };
  
  # 缩写
  abbreviations = {
    g = "git";
    gst = "git status";
  };
  
  # 插件
  plugins = [
    { name = "z"; src = pkgs.fishPlugins.z.src; }
  ];
};
```

---

### 5. Git 配置

**Dotter (文件模板):**
```ini
[user]
    name = {{git_user_name}}
    email = {{git_user_email}}
[init]
    defaultBranch = {{git_default_branch}}
```

**Nix:**
```nix
programs.git = {
  enable = true;
  userName = "Leoyzen";
  userEmail = "leoyzen@gmail.com";
  
  extraConfig = {
    init.defaultBranch = "main";
    push.autoSetupRemote = true;
  };
  
  ignores = [
    ".DS_Store"
    "*.log"
    "node_modules/"
  ];
  
  aliases = {
    st = "status";
    co = "checkout";
    lg = "log --oneline --graph";
  };
};
```

---

### 6. 条件配置（按平台）

**Dotter:**
```toml
[default.variables]
# 需要手动检测平台

[macos.files]
"config/shell/fish/macos.fish" = "~/.config/fish/conf.d/macos.fish"

[linux.files]
"config/shell/fish/linux.fish" = "~/.config/fish/conf.d/linux.fish"
```

**Nix:**
```nix
{ config, pkgs, lib, ... }:

{
  # 简洁的条件配置
  home.file.".config/fish/conf.d/platform.fish".text = 
    lib.optionalString pkgs.stdenv.isDarwin ''
      # macOS 特定配置
      set -gx HOMEBREW_NO_AUTO_UPDATE 1
      fish_add_path /opt/homebrew/bin
    ''
    + lib.optionalString pkgs.stdenv.isLinux ''
      # Linux 特定配置
      set -gx XDG_CONFIG_HOME ~/.config
    '';
  
  # 或使用 mkIf
  programs.git.extraConfig = lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isDarwin {
      credential.helper = "osxkeychain";
    })
    (lib.mkIf pkgs.stdenv.isLinux {
      credential.helper = "libsecret";
    })
  ];
}
```

---

## 🔧 常用模式转换

### 从包管理器安装工具

**Homebrew (Dotter):**
```bash
brew install --cask font-jetbrains-mono
brew install helix tmux fzf
```

**Nix:**
```nix
home.packages = with pkgs; [
  # 字体
  jetbrains-mono
  
  # 工具
  helix
  tmux
  fzf
  
  # macOS 特定
  (lib.mkIf pkgs.stdenv.isDarwin lima)
];
```

---

### 服务和守护进程

**Dotter:** 需手动启动/配置

**Nix:**
```nix
# 启用服务
services.gpg-agent.enable = true;
services.ssh-agent.enable = true;

# macOS 特定服务
launchd.agents.myservice = {
  enable = true;
  config = {
    ProgramArguments = [ "/path/to/command" ];
    RunAtLoad = true;
    KeepAlive = true;
  };
};
```

---

## ✅ 迁移检查清单

### 准备工作
- [ ] 安装 Nix (Determinate Installer 推荐)
- [ ] 启用 Flakes (`experimental-features = nix-command flakes`)
- [ ] 安装 Home Manager
- [ ] 备份当前配置 `cp -r ~/.config ~/.config.backup`

### 配置迁移
- [ ] 基础配置 (用户名、主目录)
- [ ] Shell 配置 (Fish, Starship)
- [ ] 编辑器配置 (Helix, Zed)
- [ ] Git 配置
- [ ] 开发工具 (Rust, Python)
- [ ] 自定义文件映射
- [ ] 环境变量
- [ ] 别名和函数

### 验证
- [ ] 测试 `home-manager switch --dry-run`
- [ ] 完整部署 `home-manager switch`
- [ ] 验证所有工具正常工作
- [ ] 检查回滚 `home-manager generations`

---

## ⚠️ 常见陷阱

### 1. 字符串转义

**错误:**
```nix
home.file.".config/test".text = ''
  path = /home/user/file.txt
'';
```

**正确:**
```nix
home.file.".config/test".text = ''
  path = /home/user/file.txt
'';
# 或
home.file.".config/test".text = "
  path = ${config.home.homeDirectory}/file.txt
";
```

### 2. 包名差异

某些包在 nixpkgs 中的名称不同：

| 常见名 | Nix 包名 |
|--------|----------|
| `fd` | `fd` |
| `bat` | `bat` |
| `exa` | `eza` (已重命名) |
| `python` | `python3` |

### 3. 平台特定路径

```nix
# 不要硬编码路径
home.homeDirectory = "/Users/leoyzen";  # 仅 macOS

# 使用条件
home.homeDirectory = 
  if pkgs.stdenv.isDarwin 
  then "/Users/leoyzen" 
  else "/home/leoyzen";
```

### 4. 递归配置导入

```nix
# 错误: 相对路径问题
imports = [ ./modules/shell.nix ];

# 正确: 使用相对 flake 根的路径
imports = [ 
  ./home-manager/modules/shell.nix 
];
```

---

## 🎓 学习路径

1. **第1周**: 熟悉基础 Nix 语法
   - 阅读 [Nix Pills](https://nixos.org/guides/nix-pills/)
   - 理解 `let...in`, `with`, 属性集

2. **第2周**: Home Manager 基础
   - 浏览 [选项文档](https://nix-community.github.io/home-manager/options.xhtml)
   - 从简单配置开始 (Git, Shell)

3. **第3周**: 复杂配置
   - 编辑器配置 (Helix, Neovim)
   - 自定义模块

4. **第4周**: 高级特性
   - Flakes 和输入锁定
   - Overlays 和自定义包

---

## 📚 参考资源

- [Home Manager 手册](https://nix-community.github.io/home-manager/)
- [Nixpkgs 源码](https://github.com/NixOS/nixpkgs) - 查找包模块定义
- [NixOS Wiki](https://wiki.nixos.org/wiki/Home_Manager)
- [Misterio77's Starter Templates](https://github.com/Misterio77/nix-starter-configs)

---

> 💡 **提示**: 迁移是渐进过程，你不需要一次性完成。可以并行运行 Dotter 和 Nix，逐步迁移配置。