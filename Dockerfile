# 基础镜像 Pytorch2.0.1 + cu117
FROM hub.byted.org/reckon/data.reckon.mlx.image_3976:c1bca3508c6bec7a02de0b39a14d3e8b
# install conda

ENV HOMEBREW_INSTALL_FROM_API=1 \
    HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api" \
    HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles" \
    HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git" \
    HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
COPY entrypoint.sh /opt/tiger/bin/
COPY condarc /root/.condarc
COPY ruff.toml /root/.config/ruff/config.toml
COPY rye.toml /root/.rye/config.toml
COPY tmux.conf /root/.tmux.conf
ENTRYPOINT [ "/opt/tiger/bin/entrypoint.sh" ]