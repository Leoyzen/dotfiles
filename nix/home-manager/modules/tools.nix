# ./nix/home-manager/modules/tools.nix
# Git 和 Tmux 配置

{ config, pkgs, ... }:

{
  # ========== Git 配置 ==========
  programs.git = {
    enable = true;

    # 用户基本信息（从 .dotter/global.toml 迁移）
    userName = "Leoyzen";
    userEmail = "leoyzen@gmail.com";

    # 常用 Git 配置项
    extraConfig = {
      init.defaultBranch = "main";

      # 推送配置
      push = {
        autoSetupRemote = true;
        default = "simple";
      };

      # 拉取配置
      pull = {
        rebase = false;
      };

      # Core 设置
      core = {
        autocrlf = "input";
        safecrlf = true;
      };

      # 颜色设置
      color = {
        ui = "auto";
        diff = "auto";
        status = "auto";
        branch = "auto";
      };

      # 别名（可选）
      alias = {
        st = "status";
        co = "checkout";
        ci = "commit";
        br = "branch";
        lg = "log --oneline --graph --decorate";
      };

      # 凭证管理
      credential.helper = if pkgs.stdenv.isDarwin then "osxkeychain" else "cache";
    };

    # 忽略全局文件
    ignores = [
      # 编辑器/IDE
      ".DS_Store"
      ".idea/"
      ".vscode/"
      "*.swp"
      "*.swo"
      "*~"

      # 构建输出
      "dist/"
      "build/"
      "target/"
      "*.exe"
      "*.dll"
      "*.so"
      "*.class"

      # 依赖目录
      "node_modules/"
      "vendor/"
      "__pycache__/"
      "*.egg-info/"
      ".pytest_cache/"
      ".mypy_cache/"

      # 日志和临时文件
      "*.log"
      "*.tmp"
      ".env"
      ".env.local"
    ];

    # 启用 delta 用于更好的 diff 显示（可选）
    # delta = {
    #   enable = true;
    #   options = {
    #     navigate = true;
    #     light = false;
    #     line-numbers = true;
    #     side-by-side = false;
    #   };
    # };
  };

  # ========== Tmux 配置 ==========
  programs.tmux = {
    enable = true;

    # Tmux 配置
    baseIndex = 1;                    # 窗口从 1 开始编号
    prefix = "C-a";                   # 前缀键改为 Ctrl+a（覆盖默认值）
    terminal = "tmux-256color";

    # 自定义配置（使用 extraConfig 添加原始 tmux 配置）
    extraConfig = ''
      # ========== 基本设置 ==========
      set -g mouse on
      set -g focus-events on
      set -g status-interval 5
      set -g escape-time 10
      set -g history-limit 100000

      # ========== 窗口和面板 ==========
      setw -g pane-base-index 1
      setw -g automatic-rename on
      set -g renumber-windows on

      # ========== 分割面板键位 ==========
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # ========== 移动键位（Vim 风格）==========
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # ========== 调整面板大小 ==========
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # ========== 窗口导航 ==========
      bind -r C-h previous-window
      bind -r C-l next-window

      # ========== 复制模式（Vim 风格）==========
      setw -g mode-keys vi
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind P paste-buffer

      # ========== 状态栏样式 ==========
      set -g status-position bottom
      set -g status-justify left
      set -g status-style "bg=#1d2021,fg=#ebdbb2"

      set -g status-left-length 40
      set -g status-left "#[bg=#458588,fg=#1d2021,bold] #S #[bg=#1d2021,fg=#458588] "

      set -g status-right-length 150
      set -g status-right "#[fg=#b16286,bg=#1d2021] #{prefix_highlight} #[fg=#1d2021,bg=#b16286,bold] %Y-%m-%d %H:%M "

      set -g window-status-format "#[fg=#a89984,bg=#1d2021] #I:#W "
      set -g window-status-current-format "#[fg=#1d2021,bg=#d79921,bold] #I:#W "
      set -g window-status-separator ""

      # ========== 面板边框样式 ==========
      set -g pane-border-style "fg=#504945"
      set -g pane-active-border-style "fg=#fabd2f"

      # ========== 消息样式 ==========
      set -g message-style "bg=#d79921,fg=#1d2021,bold"
      set -g message-command-style "bg=#1d2021,fg=#fabd2f"
    '';
  };
}
