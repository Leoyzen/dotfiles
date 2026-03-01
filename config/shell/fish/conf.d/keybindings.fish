# sudo
bind --user \cs 'fish_commandline_prepend "sudo -E"'

# proxychain keybinding
if command -v proxychains >/dev/null
  bind --user \cq 'fish_commandline_prepend "proxychains -q"'
else if command -v proxychains4 >/dev/null
  bind --user \cq 'fish_commandline_prepend "proxychains4 -q"'
end
