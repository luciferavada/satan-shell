## Aliases
#  Sudo with an alias as a command (trailing space is for alias expansion)
alias sudo="sudo "

#  Launctl shortcut
alias lctl="launchctl"

#  VBoxManage shortcut
alias vbm="VBoxManage"

#  Make open to work in tmux
alias open="reattach-to-user-namespace open"

#  Corolize Traceroute
alias traceroute="grc traceroute"

#  Colorize Ping
alias ping="grc ping"

## Functions
#  Disk Usage
function dh() {
  local DIRECTORY=${1:-"${PWD}"}
  sudo grc du -d "1" -hsc "${DIRECTORY}" | gsort -bhr
}

#  Inspect DNS traffic
function dnsdump() {
  local DEVICE=${1:-"en0"}
  sudo tcpdump -i "${DEVICE}" -l -n -t --snapshot-length "0" "port 53" \
    | sed "s/.*:\ \(.*\)/\1/"
}
