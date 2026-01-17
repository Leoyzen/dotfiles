# 根据平台设置 Homebrew 路径
if test (uname) = "Darwin"
    set -x HOMEBREW_PREFIX /opt/homebrew
    set -x HOMEBREW_CELLAR /opt/homebrew/Cellar
    set -x HOMEBREW_REPOSITORY /opt/homebrew
else
    set -x HOMEBREW_PREFIX $HOME/.linuxbrew
    set -x HOMEBREW_CELLAR $HOME/.linuxbrew/Cellar
    set -x HOMEBREW_REPOSITORY $HOME/.linuxbrew/Homebrew
end

set -x MANPATH $HOMEBREW_PREFIX/share/man $MANPATH
set -x INFOPATH $HOMEBREW_PREFIX/share/info $INFOPATH

# 镜像源
if test (uname) = "Darwin"
    set -x HOMEBREW_BOTTLE_DOMAIN https://mirrors.ustc.edu.cn/homebrew-bottles
else
    set -x HOMEBREW_BOTTLE_DOMAIN https://mirrors.ustc.edu.cn/linuxbrew-bottles
end
