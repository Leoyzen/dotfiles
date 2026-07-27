{ config, pkgs, ... }:

{
  # ============================================
  # Python 开发工具
  # ============================================

  home.packages = with pkgs; [
    # Python 版本管理器
    uv          # 现代的 Python 包管理器（替代 pip + venv）

    # Python 代码工具
    ruff        # 极快的 Python linter 和 formatter
    black       # Python 代码格式化工具

    # 其他常用 Python 工具（可选）
    # poetry
    # pyenv
  ];

  # UV 配置
  # 原生 Nix 配置方式（将 TOML 转换为 Nix 属性集）
  xdg.configFile."uv/uv.toml".text = ''
    # UV 配置文件
    # 参见: https://docs.astral.sh/uv/configuration/files/

    [pip]
    # 使用国内的 PyPI 镜像（如需）
    # index-url = "https://pypi.tuna.tsinghua.edu.cn/simple"

    [python]
    # 默认 Python 版本偏好
    # preference = "only-system"
  '';

  # Ruff 配置（从现有 TOML 转换）
  xdg.configFile."ruff/ruff.toml".text = ''
    # Ruff 配置
    # 行长度限制
    line-length = 88

    # 选择规则
    select = [
        "E",   # pycodestyle errors
        "W",   # pycodestyle warnings
        "F",   # Pyflakes
        "I",   # isort
        "N",   # pep8-naming
        "B",   # flake8-bugbear
        "C4",  # flake8-comprehensions
        "UP",  # pyupgrade
    ]

    # 忽略的规则
    ignore = [
        "E501",  # line too long (handled by formatter)
    ]

    [format]
    # 使用双引号
    quote-style = "double"
    # 使用空格缩进
    indent-style = "space"
    # 缩进宽度
    indent-width = 4

    [lint.pydocstyle]
    convention = "google"
  '';

  # ============================================
  # Rust 开发工具
  # ============================================

  home.packages = with pkgs; [
    # Rust 工具链
    rustc        # Rust 编译器
    cargo        # Rust 包管理器
    rustfmt      # Rust 代码格式化工具
    clippy       # Rust linter

    # 额外的 Rust 工具
    rust-analyzer  # LSP 服务器
  ];

  # Cargo 配置（从现有 cargo/config 转换）
  xdg.configFile."cargo/config.toml".text = ''
    [registry]
    default = "crates-io"

    [source.crates-io]
    # 如需使用国内镜像，取消下面注释
    # replace-with = 'ustc'

    # 中国科学技术大学镜像
    # [source.ustc]
    # registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

    [build]
    # 使用所有 CPU 核心编译
    jobs = 0

    [target.x86_64-unknown-linux-gnu]
    # linker = "clang"
    # rustflags = ["-C", "link-arg=-fuse-ld=lld"]

    [target.aarch64-apple-darwin]
    # macOS ARM64 特定配置

    [alias]
    b = "build"
    c = "check"
    t = "test"
    r = "run"
  '';

  # rustfmt 配置
  xdg.configFile."rustfmt/rustfmt.toml".text = ''
    # Rustfmt 配置
    # 最大行宽
    max_width = 100

    # 使用小括号格式
    use_small_heuristics = "Default"

    # 注释格式化
    wrap_comments = true
    format_code_in_doc_comments = true

    # 导入排序
    group_imports = "StdExternalCrate"
    imports_granularity = "Crate"

    # 其他格式选项
    tab_spaces = 4
    hard_tabs = false
    edition = "2021"
  '';

  # ============================================
  # 环境变量
  # ============================================

  home.sessionVariables = {
    # Rust/Cargo
    CARGO_HOME = "${config.home.homeDirectory}/.cargo";
    RUSTUP_HOME = "${config.home.homeDirectory}/.rustup";

    # Python
    # UV 相关环境变量
    UV_CACHE_DIR = "${config.home.homeDirectory}/.cache/uv";
  };

  # ============================================
  # 添加到 PATH
  # ============================================

  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
  ];
}
