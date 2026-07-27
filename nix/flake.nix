{
  description = "Leoyzen's dotfiles - Home Manager configuration";

  inputs = {
    # Nixpkgs 源
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Darwin 支持（macOS）
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }:
    let
      # 支持的系统架构
      systems = [
        "aarch64-darwin"   # Apple Silicon Mac
        "x86_64-darwin"    # Intel Mac
        "x86_64-linux"     # Intel/AMD Linux
        "aarch64-linux"    # ARM Linux
      ];

      # 为每个系统创建 pkgs
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # 通用配置
      username = "leoyzen";

      # 根据系统确定主目录
      homeDirectory = system:
        if nixpkgs.lib.hasSuffix "darwin" system
        then "/Users/${username}"
        else "/home/${username}";

      # 创建 Home Manager 配置的辅助函数
      mkHomeConfiguration = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit system;
          };
          modules = [
            ./home-manager/home.nix
            {
              home = {
                inherit username;
                homeDirectory = homeDirectory system;
                stateVersion = "24.11";
              };
            }
          ];
        };

    in {
      # Home Manager 配置
      homeConfigurations = {
        # macOS Apple Silicon
        "leoyzen@macos-arm" = mkHomeConfiguration "aarch64-darwin";

        # macOS Intel
        "leoyzen@macos-intel" = mkHomeConfiguration "x86_64-darwin";

        # Linux x86_64
        "leoyzen@linux-x86" = mkHomeConfiguration "x86_64-linux";

        # Linux ARM
        "leoyzen@linux-arm" = mkHomeConfiguration "aarch64-linux";

        # 通用配置（自动检测架构）
        ${username} = mkHomeConfiguration (
          if self ? currentSystem
          then self.currentSystem
          else "aarch64-darwin"  # 默认
        );
      };

      # Formatter for all systems
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      # Development shell
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs = with nixpkgs.legacyPackages.${system}; [
            home-manager
            nixpkgs-fmt
          ];
        };
      });
    };
}
