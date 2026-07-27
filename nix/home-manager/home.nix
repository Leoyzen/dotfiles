# Home Manager 主入口文件
# 使用: home-manager switch -f ./home.nix
# 或 Flake: home-manager switch --flake .#leoyzen

{ config, pkgs, lib, ... }:

{
  # 导入模块化配置
  imports = [
    ./modules/shell.nix
    ./modules/editors.nix
    ./modules/tools.nix
    ./modules/dev-tools.nix
    ./modules/ai-tools.nix
  ];

  # 基础用户信息 - 请根据你的环境修改
  home.username = "leoyzen";
  home.homeDirectory = lib.mkForce "/Users/leoyzen";  # macOS 路径
  # home.homeDirectory = "/home/leoyzen";  # Linux 路径

  # Home Manager 版本，建议使用当前年份.11 格式
  home.stateVersion = "24.11";

  # 安装基础包
  home.packages = with pkgs; [
    # 系统工具
    fd
    ripgrep
    fzf
    bat
    eza
    zoxide

    # 开发工具
    git
    jq
    yq
  ];

  # 允许 Home Manager 管理自身
  programs.home-manager.enable = true;

  # 启用检查
  home.enableNixpkgsReleaseCheck = false;
}
