## Tmux
#  Default session name
local TMUX_DEFAULT_SESSION="default"

#  Create or attach to a tmux session
function tmux-session() {
  tmux new-session -A -c "${HOME}" -n "${1:-${TMUX_DEFAULT_SESSION}}" \
    -s "${1:-${TMUX_DEFAULT_SESSION}}"
}

#  List tmux sessions
function tmux-list() {
  tmux list-sessions
}
