# ============================================================
# 编辑器配置模块 (Helix, Zed, Vim)
# ============================================================

{ config, pkgs, ... }:

{
  # ------------------------------------------------------------
  # Helix 编辑器
  # ------------------------------------------------------------
  programs.helix = {
    enable = true;

    settings = {
      theme = "gruvbox-material-dark-hard";

      editor = {
        auto-save = true;
        auto-format = true;
        bufferline = "multiple";
        color-modes = true;
        completion-replace = true;
        cursorcolumn = false;
        cursorline = true;
        line-number = "relative";
        mouse = true;
        rulers = [ 79 ];
        true-color = true;

        whitespace = {
          render = {
            space = "none";
            nbsp = "none";
            tab = "none";
            newline = "none";
          };
          characters = {
            space = "·";
            nbsp = "⍽";
            tab = "→";
            newline = "⏎";
            tabpad = "·";
          };
        };

        file-picker = {
          hidden = false;
          git-ignore = false;
        };

        statusline = {
          left = [
            "mode"
            "spacer"
            "version-control"
            "spacer"
            "separator"
            "file-name"
            "file-modification-indicator"
          ];
          right = [
            "spinner"
            "spacer"
            "workspace-diagnostics"
            "separator"
            "spacer"
            "diagnostics"
            "position"
            "file-encoding"
            "file-line-ending"
            "file-type"
          ];
          separator = "╎";
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        indent-guides = {
          render = true;
          character = "╎";
          skip-levels = 0;
        };

        soft-wrap = {
          enable = true;
          max-wrap = 10;
          max-indent-retain = 40;
        };
      };

      # 键位映射（当前保留默认，可取消注释自定义）
      keys = {
        normal = {
          # "C-/" = "toggle_comments";
          # "esc" = [ "collapse_selection" "keep_primary_selection" ":w" ];
          # "C-v" = "vsplit";
        };

        insert = {
          # 移除方向键的 "训练轮"（VSCode 习惯）
          # up = "no_op";
          # down = "no_op";
          # left = "no_op";
          # right = "no_op";
        };
      };
    };

    # 语言配置
    languages = {
      language-server = {
        rust-analyzer = {
          config = {
            check = {
              command = "clippy";
            };
            cargo = {
              features = "all";
            };
          };
        };
        pylsp = {
          config = {
            pylsp = {
              plugins = {
                ruff = {
                  enabled = true;
                  extendSelect = [ "I" ];
                };
                black = {
                  enabled = true;
                };
              };
            };
          };
        };
      };

      language = [
        {
          name = "rust";
          language-servers = [ "rust-analyzer" ];
          indent = {
            tab-width = 4;
            unit = "    ";
          };
        }
        {
          name = "python";
          language-servers = [ "pylsp" ];
          formatter = {
            command = "black";
            args = [ "--quiet" "-" ];
          };
        }
        {
          name = "nix";
          formatter = {
            command = "nixfmt";
          };
        }
      ];
    };

    # 额外的语法高亮和主题
    themes = {
    };
  };

  # ------------------------------------------------------------
  # Zed 编辑器（Home Manager 原生支持）
  # ------------------------------------------------------------
  # 说明:
  # - 包名: zed-editor (nixpkgs 24.11+)
  # - CLI 命令: zeditor (注意不是 zed，因为与 zed 数据库冲突)
  # - 扩展通过 extensions 列表声明式安装
  # - 主题也是作为扩展安装的

  programs.zed-editor = {
    enable = true;

    # 声明式安装扩展
    extensions = [
      "nix"           # Nix 语言支持
      "toml"          # TOML 支持
      "lua"           # Lua 支持
      "catppuccin-icons"  # 图标主题
      "color-highlight"   # 颜色高亮
    ];

    # 用户设置 (对应 settings.json)
    userSettings = {
      # 主题和外观
      theme = {
        mode = "system";
        light = "One Light";
        dark = "Gruvbox Dark Hard";
      };
      icon_theme = "Catppuccin Icons";

      # 编辑行为
      vim_mode = true;
      relative_line_numbers = true;
      auto_save = "on_focus_change";
      tab_size = 4;
      soft_wrap = "editor_width";

      # 字体设置
      buffer_font_size = 14;
      buffer_font_family = "JetBrains Mono";
      ui_font_size = 13;
      ui_font_family = "SF Pro Text";

      # 终端配置
      terminal = {
        alternate_scroll = "off";
        blinking = "off";
        copy_on_select = false;
        dock = "bottom";
        detect_vshell = true;
        env = {
          TERM = "xterm-256color";
        };
      };

      # LSP 配置
      lsp = {
        nix = {
          binary = {
            path_lookup = true;
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
          };
        };
      };

      # 语言特定设置
      languages = {
        "Nix" = {
          language_servers = [ "nixd" "nil" ];
          formatter = {
            external = {
              command = "nixfmt";
              arguments = [ ];
            };
          };
        };
      };

      # 文件关联
      file_types = {
        "TOML" = [ "Pipfile" "poetry.lock" ".cz.toml" ];
        "Nix" = [ "flake.lock" ];
      };

      # AI 助手配置 (可选)
      assistant = {
        enabled = true;
        default_model = {
          provider = "zed.dev";
          model = "claude-3-5-sonnet-latest";
        };
        version = "2";
      };

      # 项目管理
      project_panel = {
        dock = "left";
        git_status = true;
      };

      # 自动安装扩展
      auto_install_extensions = {
        nix = true;
        toml = true;
      };
    };

    # 键位映射 (对应 keymap.json)
    userKeymaps = [
      {
        context = "Editor";
        bindings = {
          "ctrl-w" = "pane::CloseActiveItem";
          "ctrl-," = "zed::OpenSettings";
          # Vim 风格的窗口导航
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-j" = "workspace::ActivatePaneDown";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-l" = "workspace::ActivatePaneRight";
          # 文件查找
          "ctrl-p" = "file_finder::Toggle";
          "ctrl-shift-p" = "command_palette::Toggle";
          # 符号搜索
          "ctrl-shift-o" = "outline::Toggle";
          "ctrl-t" = "project_symbols::Toggle";
          # 终端
          "ctrl-\\" = "terminal_panel::ToggleFocus";
        };
      }
      {
        context = "Workspace";
        bindings = {
          "ctrl-shift-t" = "workspace::NewTerminal";
          "ctrl-shift-n" = "workspace::NewFile";
        };
      }
      {
        context = "Terminal";
        bindings = {
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-j" = "workspace::ActivatePaneDown";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-l" = "workspace::ActivatePaneRight";
        };
      }
    ];
  };

  # 确保 nixd LSP 服务器已安装 (Zed Nix 支持需要)
  home.packages = with pkgs; [
    nixd        # Nix 语言服务器
    nil         # 备选 Nix LSP
    nixfmt-rfc-style  # Nix 格式化工具
  ];

  # ------------------------------------------------------------
  # Vim / SpaceVim
  # ------------------------------------------------------------
  programs.vim = {
    enable = true;

    # Vim 基本配置
    settings = {
      number = true;
      relativenumber = true;
      mouse = "a";
      tabstop = 4;
      shiftwidth = 4;
      expandtab = true;
    };

    # 插件管理（使用 vim-plug 或 native 方式）
    # 建议选择：SpaceVim 或自己管理插件
    extraConfig = ''
      " SpaceVim 初始化文件路径
      " 如果你使用 SpaceVim，需要创建 ~/.SpaceVim.d/init.toml
    '';
  };

  # SpaceVim 配置目录
  home.file.".spacevim".text = ''
    " =============================================================================
    " SpaceVim 配置文件
    " =============================================================================

    " 启用/禁用 Layer
    let g:spacevim_layers = [
      \ 'checkers',
      \ 'edit',
      \ 'ui',
      \ 'core',
      \ 'fzf',
      \ 'git',
      \ 'shell',
      \ 'tools',
      \ 'lang#python',
      \ 'lang#rust',
      \ 'lang#nix',
      \ 'lang#toml',
      \ 'lang#json',
      \ ]

    " 自定义变量
    let g:spacevim_colorscheme = 'gruvbox'
    let g:spacevim_colorscheme_bg = 'dark'
    let g:spacevim_enable_tabline_ft_icon = 1
    let g:spacevim_enable_language_specific_leader = 1

    " 禁用默认键位（如果你自定义）
    " let g:spacevim_enable_insert_modeleader = 0

    " 自定义插件
    let g:spacevim_custom_plugins = [
      \ ['iamcco/markdown-preview.nvim', {'on_ft': ['markdown', 'pandoc.markdown', 'rmd'], 'build': 'cd app && yarn install'}],
      \ ]

    " 自定义键位映射
    function! UserInit() abort
      " 在此处添加自定义初始化
    endfunction

    function! UserConfig() abort
      " 在此处添加自定义配置
      " 例如：设置行号显示
      set number
      set relativenumber
    endfunction
  '';
}
