# Use vim keybindings in copy mode
setw -g mode-keys vi

# Setup 'v' to begin selection as in Vim
bind-key -t vi-copy v begin-selection
bind-key -t vi-copy y copy-pipe "reattach-to-user-namespace pbcopy"

# Update default binding of `Enter` to also use copy-pipe
unbind -t vi-copy Enter
bind-key -t vi-copy Enter copy-pipe "reattach-to-user-namespace pbcopy"
tmux list-keys -t vi-copy

set-option -g default-shell /home/linuxbrew/.linuxbrew/bin/fish
set -g default-terminal "screen-256color"
set-option -ga terminal-overrides ",xterm-256color:Tc"
