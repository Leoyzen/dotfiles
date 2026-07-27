{ config, pkgs, ... }:

{
  # ============================================
  # Fish Shell
  # ============================================
  programs.fish = {
    enable = true;

    # 交互式 shell 初始化
    interactiveShellInit = ''
      # 设置环境变量
      set -gx EDITOR hx

      # 启用 vi 模式（可选）
      # fish_vi_key_bindings

      # FZF 默认命令
      set -gx FZF_DEFAULT_COMMAND "fd --type file --color=always"
      set -gx FZF_DEFAULT_OPTS "--ansi"
    '';

    # Fish 函数
    functions = {
      # 自定义函数示例
      ll = "ls -la $argv";
      cls = "clear";
    };

    # 缩写（abbreviations）- Fish 的智能别名
    abbreviations = {
      g = "git";
      gst = "git status";
      gco = "git checkout";
      gp = "git push";
      gl = "git pull";
      d = "docker";
      k = "kubectl";
      n = "nix";
      hm = "home-manager";
    };

    # 插件（通过 home-manager 管理）
    plugins = [
      # 你可以在这里添加插件，例如：
      # { name = "z"; src = pkgs.fishPlugins.z.src; }
      # { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
      # { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
    ];
  };

  # ============================================
  # Starship Prompt - Nix 原生配置
  # ============================================
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      # 格式字符串 - 使用 Gruvbox 主题
      format = ''
        [](color_orange)\
        $os\
        $username\
        [](bg:color_yellow fg:color_orange)\
        $directory\
        [](fg:color_yellow bg:color_aqua)\
        $git_branch\
        $git_status\
        [](fg:color_aqua bg:color_blue)\
        $c\
        $rust\
        $golang\
        $nodejs\
        $php\
        $java\
        $kotlin\
        $haskell\
        $python\
        [](fg:color_blue bg:color_bg3)\
        $docker_context\
        $conda\
        [](fg:color_bg3 bg:color_bg1)\
        $time\
        [ ](fg:color_bg1)\
        $line_break$character'';

      # ========== 调色板 ==========
      palette = "gruvbox_dark";

      palettes.gruvbox_dark = {
        color_fg0 = "#fbf1c7";
        color_bg1 = "#3c3836";
        color_bg3 = "#665c54";
        color_blue = "#458588";
        color_aqua = "#689d6a";
        color_green = "#98971a";
        color_orange = "#d65d0e";
        color_purple = "#b16286";
        color_red = "#cc241d";
        color_yellow = "#d79921";
      };

      # ========== OS 模块 ==========
      os = {
        disabled = false;
        style = "bg:color_orange fg:color_fg0";
        symbols = {
          Windows = "󰍲";
          Ubuntu = "󰕈";
          SUSE = "";
          Raspbian = "󰐿";
          Mint = "󰣭";
          Macos = "󰀵";
          Manjaro = "";
          Linux = "󰌽";
          Gentoo = "󰣨";
          Fedora = "󰣛";
          Alpine = "";
          Amazon = "";
          Android = "";
          Arch = "󰣇";
          Artix = "󰣇";
          CentOS = "";
          Debian = "󰣚";
          Redhat = "󱄛";
          RedHatEnterprise = "󱄛";
        };
      };

      # ========== 用户名 ==========
      username = {
        show_always = true;
        style_user = "bg:color_orange fg:color_fg0";
        style_root = "bg:color_orange fg:color_fg0";
        format = "[$user ]($style)";
      };

      # ========== 目录 ==========
      directory = {
        style = "fg:color_fg0 bg:color_yellow";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = "󰝚 ";
          "Pictures" = " ";
          "Developer" = "󰲋 ";
        };
      };

      # ========== Git ==========
      git_branch = {
        symbol = "";
        style = "bg:color_aqua";
        format = "[[ $symbol $branch ](fg:color_fg0 bg:color_aqua)]($style)";
      };

      git_status = {
        style = "bg:color_aqua";
        format = "[[($all_status$ahead_behind )](fg:color_fg0 bg:color_aqua)]($style)";
      };

      # ========== 编程语言 ==========
      nodejs = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      c = {
        symbol = " ";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      php = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      java = {
        symbol = " ";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      kotlin = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      haskell = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      python = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      # ========== Docker & Conda ==========
      docker_context = {
        symbol = "";
        style = "bg:color_bg3";
        format = "[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)";
      };

      conda = {
        style = "bg:color_bg3";
        format = "[[ $symbol( $environment) ](fg:#83a598 bg:color_bg3)]($style)";
      };

      # ========== 时间 ==========
      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:color_bg1";
        format = "[[  $time ](fg:color_fg0 bg:color_bg1)]($style)";
      };

      line_break = {
        disabled = false;
      };

      # ========== 提示符字符 ==========
      character = {
        disabled = false;
        success_symbol = "[](bold fg:color_green)";
        error_symbol = "[](bold fg:color_red)";
        vimcmd_symbol = "[](bold fg:color_green)";
        vimcmd_replace_one_symbol = "[](bold fg:color_purple)";
        vimcmd_replace_symbol = "[](bold fg:color_purple)";
        vimcmd_visual_symbol = "[](bold fg:color_yellow)";
      };
    };
  };

  # ============================================
  # 其他 Shell 工具
  # ============================================

  # Zoxide - 智能 cd 工具
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd cd" ];  # 使用 cd 代替 z
  };

  # FZF - 模糊查找
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultCommand = "fd --type file --color=always";
    defaultOptions = [ "--ansi" "--preview 'bat --color=always {}'" ];
  };

  # 安装相关包
  home.packages = with pkgs; [
    fd        # find 的替代
    ripgrep   # grep 的替代
    bat       # cat 的替代（带高亮）
    eza       # ls 的替代
    zoxide    # cd 增强
  ];
}
