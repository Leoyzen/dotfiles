# AI 工具模块 - opencode + oh-my-opencode
# opencode: 开源 AI 编程助手 (nixpkgs 可用)
# oh-my-opencode: opencode 的增强插件 (需通过 npm 安装)

{ config, pkgs, lib, ... }:

{
  # ============================================
  # 包安装
  # ============================================

  home.packages = with pkgs; [
    # opencode 本体 - 从 nixpkgs 安装
    opencode

    # oh-my-opencode 依赖
    # oh-my-opencode 本身没有 Nix 包，需要通过 npm/bun 安装
    # 使用 bun 比 npm 更快
    bun
    nodejs

    # LSP 支持（opencode 配置中使用的）
    marksman  # Markdown LSP
  ];

  # ============================================
  # opencode 配置
  # ============================================

  # 主配置文件
  xdg.configFile."opencode/opencode.jsonc".source =
    ../../../../opencode/opencode.jsonc;

  # oh-my-opencode 配置
  xdg.configFile."opencode/oh-my-opencode.jsonc".source =
    ../../../../opencode/oh-my-opencode.jsonc;

  # antigravity 配置
  xdg.configFile."opencode/antigravity.json".source =
    ../../../../opencode/antigravity.json;

  # rootcloud-models 配置（如果存在）
  xdg.configFile."opencode/rootcloud-models.json".source =
    ../../../../opencode/rootcloud-models.json;

  # commands 目录
  xdg.configFile."opencode/command" = {
    source = ../../../../opencode/command;
    recursive = true;
  };

  # skills 目录
  xdg.configFile."opencode/skill" = {
    source = ../../../../opencode/skill;
    recursive = true;
  };

  # ============================================
  # oh-my-opencode 安装脚本
  # ============================================
  # 注意: oh-my-opencode 没有 Nix 原生包，需要通过 npm 安装
  # 初次使用需要运行: install-oh-my-opencode

  home.file.".local/bin/install-oh-my-opencode" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      echo "Installing oh-my-opencode..."

      # 使用 bun 安装更快
      if command -v bun &> /dev/null; then
        bunx oh-my-opencode install
      else
        npx oh-my-opencode install
      fi

      echo "oh-my-opencode installed successfully!"
      echo "Restart opencode to use oh-my-opencode features."
    '';
  };

  # ============================================
  # 环境变量
  # ============================================

  home.sessionVariables = {
    # opencode 相关环境变量
    OPENCODE_CONFIG_DIR = "${config.xdg.configHome}/opencode";

    # MCP 路由器令牌（如果设置）
    # MCPR_TOKEN = "";  # 通过用户本地配置设置

    # Context7 API 密钥（如果设置）
    # CONTEXT7_API_KEY = "";  # 通过用户本地配置设置
  };

  # ============================================
  # Shell 集成
  # ============================================

  programs.fish = lib.mkIf config.programs.fish.enable {
    # opencode 缩写
    shellAbbrs = {
      oc = "opencode";
      ocs = "opencode --skill";
    };

    # opencode 初始化
    interactiveShellInit = ''
      # opencode 自动补全（如果可用）
      if command -v opencode &> /dev/null
        # 检查 opencode 是否提供补全
        if opencode completion fish &> /dev/null 2>&1
          opencode completion fish | source
        end
      end
    '';
  };

  # Bash 补全支持
  programs.bash = lib.mkIf config.programs.bash.enable {
    initExtra = ''
      # opencode 补全
      if command -v opencode &> /dev/null; then
        if opencode completion bash &> /dev/null 2>&1; then
          eval "$(opencode completion bash)"
        fi
      fi
    '';
  };

  # Zsh 补全支持
  programs.zsh = lib.mkIf config.programs.zsh.enable {
    initExtra = ''
      # opencode 补全
      if command -v opencode &> /dev/null; then
        if opencode completion zsh &> /dev/null 2>&1; then
          eval "$(opencode completion zsh)"
        fi
      fi
    '';
  };

  # ============================================
  # 使用说明
  # ============================================
  #
  # 首次设置:
  # 1. 应用 Home Manager 配置: home-manager switch --flake .#leoyzen
  # 2. 安装 oh-my-opencode 插件: install-oh-my-opencode
  # 3. 重启终端开始使用
  #
  # 常用命令:
  # - opencode        # 启动 opencode
  # - opencode --skill <skill-name>  # 使用特定 skill
  # - install-oh-my-opencode  # 重新安装 oh-my-opencode
  #
  # 配置位置:
  # - ~/.config/opencode/opencode.jsonc
  # - ~/.config/opencode/oh-my-opencode.jsonc
  #
  # 限制:
  # - oh-my-opencode 需要通过 npm/bun 安装，不是纯 Nix 方案
  # - MCP 路由器和 Context7 需要手动设置 API 密钥
}
