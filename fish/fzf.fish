# set default searching using tmux
set -gx FZF_TMUX 1
set -gx FZF_PREVIEW_COMMAND 'bat --style=numbers,changes --wrap never --color always {}'
# set -gx FZF_CTRL_T_OPTS "--min-height 30 --preview-window down:60% --preview-window noborder --preview '($FZF_PREVIEW_COMMAND) 2> /dev/null'"

# https://github.com/jethrokuan/fzf
# https://github.com/junegunn/fzf#respecting-gitignore
# We want hidden but not `.git` paths
set -gx FZF_DEFAULT_COMMAND "fd --hidden --no-ignore --follow --exclude='**/.git/'"
# https://github.com/junegunn/fzf/wiki/Examples#clipboard
# `--min-height` is useful with tiny terminal windows; e.g. for VSCode,
# especially when the preview window is important, like in git log.
# TODO: could we use
# https://github.com/fish-shell/fish-shell/blob/master/share/functions/fish_clipboard_copy.fish
# to allow this to work on multiple platforms?
set -gx FZF_DEFAULT_OPTS '--height 50% --min-height=30 --layout=reverse --color=dark
--bind="ctrl-y:execute-silent(printf {} | cut -f 2- | pbcopy)"
--bind=ctrl-u:preview-half-page-up
--bind=ctrl-d:preview-half-page-down
--bind="ctrl-o:execute-silent(code {-1})"'

set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND "--type=f"
set -gx FZF_CTRL_T_OPTS "--preview='bat --style=numbers --color=always {}'"
set -gx FZF_ALT_C_COMMAND $FZF_DEFAULT_COMMAND "--type=d"
set -gx FZF_ALT_C_OPTS "--preview='exa -T {}'"
# https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings
set -gx FZF_CTRL_R_OPTS "--preview='echo {}' --preview-window=down:3:hidden:wrap --bind='?:toggle-preview'"

function jfl --argument file --description 'fzf with jq preview'
    # cat $file | fzf-tmux -p '90%' --preview-window wrap --preview "jq $argv[3..-1] -C '$q' {f}"
    jq -c $argv[2..-1] $file | fzf-tmux -p '90%' --preview-window wrap --preview "rg {q} | jq -C . {f}"
end
