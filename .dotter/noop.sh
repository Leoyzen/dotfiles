dotfiles/.dotter/noop.sh
#!/usr/bin/env bash
# 空脚本 - 用于跳过 brew 处理
# 用法: dotter deploy --pre-deploy .dotter/noop.sh --post-deploy .dotter/noop.sh

exit 0
