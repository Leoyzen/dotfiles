# Zed 编辑器 + Nix 设置指南

本文档详细介绍如何在 Nix/NixOS 环境中配置和使用 Zed 编辑器。

## 📦 安装方式

### 方式 1: nixpkgs (推荐)

从 nixpkgs 24.11 起，`zed-editor` 已经可用：

```nix
# home.nix 或 configuration.nix
programs.zed-editor.enable = true;

# 或者作为包安装
home.packages = with pkgs; [
  zed-editor
];
```

**注意**: CLI 命令是 `zeditor`，而不是 `zed`，因为与 nixpkgs 中的 `zed` 数据库包冲突。

### 方式 2: Zed 官方 Flake

如果你需要最新版本或 unstable 功能：

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    zed.url = "github:zed-industries/zed";
  };

  outputs = { self, nixpkgs, zed, ... }:
    let
      system = "aarch64-darwin"; # 或 "x86_64-linux"
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      home.packages = [
        zed.packages.${system}.zed-editor
      ];
    };
}
```

### 方式 3: Homebrew (macOS)

如果你暂时不想用 Nix 管理 Zed：

```nix
# 通过 Homebrew 安装，Nix 只管理配置
homebrew.casks = [ "zed" ];
```

---

## ⚙️ Home Manager 配置

### 基础配置

```nix
{ config, pkgs, lib, ... }:

{
  programs.zed-editor = {
    enable = true;
    
    # 声明式安装扩展
    extensions = [
      "nix"              # Nix 语言支持
      "toml"             # TOML 支持
      "lua"              # Lua 支持
      "json"             # JSON 增强
      "catppuccin-icons" # 图标主题
      "color-highlight"  # CSS/web 颜色预览
      "git-firefly"      # Git 增强
    ];
    
    # 用户设置 (settings.json)
    userSettings = {
      vim_mode = true;
      relative_line_numbers = true;
      theme = "Gruvbox Dark Hard";
      tab_size = 4;
    };
    
    # 键位映射 (keymap.json)
    userKeymaps = [
      {
        context = "Editor";
        bindings = {
          "ctrl-p" = "file_finder::Toggle";
          "ctrl-\\" = "terminal_panel::ToggleFocus";
        };
      }
    ];
  };
}
```

### 完整配置示例

```nix
{
  programs.zed-editor = {
    enable = true;
    
    # ========== 扩展列表 ==========
    # 支持的扩展: https://github.com/zed-industries/extensions
    extensions = [
      # 语言支持
      "nix"
      "toml"
      "lua"
      "rust"
      "python"
      
      # 主题和外观
      "catppuccin-icons"
      "gruvbox-themes"
      
      # 功能增强
      "color-highlight"
      "git-firefly"
      "indent-guides"
    ];
    
    # ========== 用户设置 ==========
    userSettings = {
      # --- 外观 ---
      theme = {
        mode = "system";           # 跟随系统主题
        light = "One Light";
        dark = "Gruvbox Dark Hard";
      };
      icon_theme = "Catppuccin Icons";
      buffer_font_size = 14;
      buffer_font_family = "JetBrains Mono";
      ui_font_size = 13;
      
      # --- 编辑行为 ---
      vim_mode = true;
      vim = {
        enable_vim_sneak = true;
        toggle_relative_line_numbers = true;
      };
      relative_line_numbers = true;
      tab_size = 4;
      hard_tabs = false;
      auto_save = "on_focus_change";
      soft_wrap = "editor_width";
      format_on_save = true;
      
      # --- 终端 ---
      terminal = {
        dock = "bottom";
        detect_vshell = true;
        env = {
          TERM = "xterm-256color";
          EDITOR = "zeditor";
        };
      };
      
      # --- LSP 配置 ---
      lsp = {
        nix = {
          binary = {
            path_lookup = true;    # 自动查找 nixd/nil
          };
          settings = {
            formatting = {
              command = [ "nixfmt" ];
            };
          };
        };
        rust-analyzer = {
          binary = {
            path_lookup = true;
          };
          initialization_options = {
            cargo = {
              features = "all";
            };
            check = {
              command = "clippy";
            };
            procMacro = {
              enable = true;
            };
          };
        };
        pylsp = {
          binary = {
            path_lookup = true;
          };
          settings = {
            pylsp = {
              plugins = {
                ruff = {
                  enabled = true;
                };
                black = {
                  enabled = true;
                };
              };
            };
          };
        };
      };
      
      # --- 语言特定设置 ---
      languages = {
        "Nix" = {
          language_servers = [ "nixd" "nil" ];
          formatter = {
            external = {
              command = "nixfmt";
              arguments = [ "--quiet" ];
            };
          };
        };
        "Rust" = {
          tab_size = 4;
        };
        "Python" = {
          tab_size = 4;
          formatter = {
            external = {
              command = "black";
              arguments = [ "--quiet" "-" ];
            };
          };
        };
      };
      
      # --- 文件关联 ---
      file_types = {
        "TOML" = [ "Pipfile" "poetry.lock" ".cz.toml" "uv.lock" ];
        "Nix" = [ "flake.lock" "shell.nix" "default.nix" ];
      };
      
      # --- AI 助手 (可选) ---
      assistant = {
        enabled = true;
        default_model = {
          provider = "zed.dev";    # 或 "anthropic", "openai"
          model = "claude-3-5-sonnet-latest";
        };
        version = "2";
      };
      
      # --- 项目管理 ---
      project_panel = {
        dock = "left";
        git_status = true;
        folder_icons = true;
      };
      outline_panel = {
        dock = "right";
      };
      collaboration_panel = {
        dock = "left";
      };
      
      # --- 诊断和提示 ---
      inlay_hints = {
        enabled = true;
        show_type_hints = true;
        show_parameter_hints = true;
      };
      diagnostics = {
        warning = true;
        error = true;
        info = true;
        hint = true;
      };
      
      # --- 自动安装 ---
      auto_install_extensions = {
        nix = true;
        toml = true;
        rust = true;
      };
      
      # --- 加载 direnv ---
      load_direnv = "shell_hook";  # 自动加载 .envrc
    };
    
    # ========== 键位映射 ==========
    userKeymaps = [
      # 编辑器模式
      {
        context = "Editor";
        bindings = {
          # 基础操作
          "ctrl-w" = "pane::CloseActiveItem";
          "ctrl-," = "zed::OpenSettings";
          "ctrl-." = "zed::OpenKeymap";
          
          # Vim 风格导航
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-j" = "workspace::ActivatePaneDown";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-l" = "workspace::ActivatePaneRight";
          
          # 文件和符号
          "ctrl-p" = "file_finder::Toggle";
          "ctrl-shift-p" = "command_palette::Toggle";
          "ctrl-shift-o" = "outline::Toggle";
          "ctrl-t" = "project_symbols::Toggle";
          "ctrl-shift-f" = "project_search::ToggleFocus";
          
          # 终端
          "ctrl-\\" = "terminal_panel::ToggleFocus";
          "ctrl-`" = "terminal_panel::ToggleFocus";
          
          # LSP
          "g d" = "editor::GoToDefinition";
          "g r" = "editor::FindAllReferences";
          "g i" = "editor::GoToImplementation";
          "g h" = "editor::Hover";
          "g a" = "editor::ToggleCodeActions";
          "r n" = "editor::Rename";
          
          # 诊断导航
          "] d" = "editor::GoToDiagnostic";
          "[ d" = "editor::GoToPrevDiagnostic";
          
          # Git
          "] h" = "editor::GoToHunk";
          "[ h" = "editor::GoToPrevHunk";
        };
      }
      
      # 工作区模式
      {
        context = "Workspace";
        bindings = {
          "ctrl-shift-t" = "workspace::NewTerminal";
          "ctrl-shift-n" = "workspace::NewFile";
          "ctrl-shift-w" = "workspace::CloseWindow";
        };
      }
      
      # 终端模式
      {
        context = "Terminal";
        bindings = {
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-j" = "workspace::ActivatePaneDown";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-l" = "workspace::ActivatePaneRight";
          "ctrl-\\" = "terminal_panel::ToggleFocus";
        };
      }
      
      # 项目面板 (类似 Netrw)
      {
        context = "ProjectPanel && not_editing";
        bindings = {
          "a" = "project_panel::NewFile";
          "A" = "project_panel::NewDirectory";
          "r" = "project_panel::Rename";
          "d" = "project_panel::Delete";
          "x" = "project_panel::Cut";
          "c" = "project_panel::Copy";
          "p" = "project_panel::Paste";
          "q" = "workspace::ToggleLeftDock";
          "space e" = "workspace::ToggleLeftDock";
          "Return" = "project_panel::Open";
        };
      }
      
      # Vim 正常模式
      {
        context = "Editor && VimControl && !VimWaiting && !menu";
        bindings = {
          # 快速保存
          "space w" = "workspace::Save";
          "space q" = "pane::CloseActiveItem";
          "space space" = "file_finder::Toggle";
          
          # Buffer 导航
          "shift-h" = "pane::ActivatePrevItem";
          "shift-l" = "pane::ActivateNextItem";
          
          # 面板切换
          "space e" = "workspace::ToggleLeftDock";
          "space t" = "terminal_panel::ToggleFocus";
          
          # 搜索
          "space /" = "pane::DeploySearch";
          "space *" = "search::SelectNextMatch";
          "space #" = "search::SelectPrevMatch";
          
          # Git
          "space g g" = "editor::ToggleGitBlame";
          "space g d" = "editor::ToggleDiff";
          
          # LSP
          "space r n" = "editor::Rename";
          "space c a" = "editor::ToggleCodeActions";
          "space f m" = "editor::Format";
        };
      }
    ];
  };
  
  # 确保需要的 LSP 和工具已安装
  home.packages = with pkgs; [
    nixd                    # Nix LSP
    nil                     # 备选 Nix LSP
    nixfmt-rfc-style        # Nix 格式化
    rust-analyzer           # Rust LSP
    python3Packages.python-lsp-server  # Python LSP
    ruff                    # Python linter/formatter
    black                   # Python formatter
  ];
}
```

---

## 🔧 常用命令

```bash
# 启动 Zed
zeditor                    # CLI 命令
# 或
zeditor /path/to/project   # 打开特定项目
zeditor file.txt:10        # 打开文件并跳转到第10行

# 命令面板快捷键
Cmd+Shift+P (macOS)
Ctrl+Shift+P (Linux)
```

---

## ⚠️ NixOS 特定注意事项

### 问题：动态链接二进制文件

Zed 会尝试下载自己的动态链接 Node 二进制文件用于某些功能（如 AI 助手），这在 NixOS 上会导致错误。

### 解决方案 1：使用 FHS 用户环境

```nix
# configuration.nix
users.users.yourname = {
  packages = with pkgs; [
    (buildFHSEnv {
      name = "zeditor-fhs";
      targetPkgs = pkgs: with pkgs; [
        zed-editor
        nodejs    # 提供 node
      ];
      runScript = "zeditor";
    })
  ];
};
```

### 解决方案 2：配置 Node 路径（如果 Zed 支持）

某些功能允许配置外部 Node 路径：

```json
// settings.json
{
  "node": {
    "path": "/run/current-system/sw/bin/node"
  }
}
```

### 解决方案 3：使用 nix-ld（不推荐用于 Zed）

```nix
# configuration.nix
programs.nix-ld.enable = true;
```

---

## 🎨 主题推荐

通过扩展安装的主题：

```nix
extensions = [
  "gruvbox-themes"      # Gruvbox 主题系列
  "catppuccin"          # Catppuccin 主题
  "dracula"             # Dracula 主题
  "tokyo-night"         # Tokyo Night
  "one-dark-pro"        # One Dark Pro
  "github-dark-default" # GitHub 主题
];
```

---

## 🔗 相关资源

- [Zed 扩展仓库](https://github.com/zed-industries/extensions)
- [Zed NixOS Wiki](https://wiki.nixos.org/wiki/Zed)
- [nix-zed-extensions](https://github.com/DuskSystems/nix-zed-extensions) - 第三方扩展管理
- [Nix 扩展页面](https://zed.dev/extensions/nix)

---

## ❓ 故障排除

### Zed 找不到语言服务器

确保 LSP 在 PATH 中：

```nix
home.packages = [ pkgs.nixd pkgs.nil ];
# 并在 userSettings.lsp.nix.binary.path_lookup = true;
```

### 扩展安装失败

尝试手动安装后查看日志，或使用 `auto_install_extensions` 自动安装。

### 字体显示问题

确保字体已安装：

```nix
home.packages = [ pkgs.jetbrains-mono ];
```
