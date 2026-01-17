if command -v zoxide >/dev/null
  status --is-interactive; and zoxide init fish | source
end
