## ZShell Settings
#  If the glob is empty, nullglob will remove the glob argument from the
#  list and supress the `no matches found` error.
setopt +o nullglob


## ZShell Configuration
#  ZShell configuration directory
local ZSHRC_DIRECTORY=(${HOME}/.zsh.d/*)

# Load all files in the ZShell configuration directory
if [ -n "${ZSHRC_DIRECTORY}" ]; then
  for file in ${ZSHRC_DIRECTORY}; do
    source "${file}"
  done
fi


## TTY Settings
#  Enable forward history search (CTRL+s)
stty -ixon


## General
#  Sudo with an alias as a command (trailing space is for alias expansion)
alias sudo="sudo "

#  Launctl shortcut
alias lctl="launchctl"

#  Reload ZSH configuration
alias reload="source ${HOME}/.zshrc"

#  VBoxManage shortcut
alias vbm="VBoxManage"

#  Make open to work in tmux
alias open="reattach-to-user-namespace open"

#  Python VirtualEnv
alias virtualenv="${HOME}/Library/Python/2.7/bin/virtualenv"

#  TinTin
alias tintin="tt++"

#  Corolize Traceroute
alias traceroute="grc traceroute"

#  Colorize Ping
alias ping="grc ping"

#  Corolize Docker
alias docker="grc docker"


## Utility Functions
#  Disk Usage
function dh() {
  local DIRECTORY=${1:-"${PWD}"}
  sudo grc du -d "1" -hsc "${DIRECTORY}" | gsort -bhr
}


## TinTin Functions
#  Login to Toril MUD
function torilmud() {
  local CONFIG="${HOME}/.toril/main.tt"
  local SESSION="#session toril torilmud.org 9999"
  tintin -G -r "${CONFIG}" -e "${SESSION}" ${@}
}


## TCPDump Functions
#  Inspect DNS traffic
function dnsdump() {
  local DEVICE=${1:-"en0"}
  sudo tcpdump -i "${DEVICE}" -l -n -t --snapshot-length "0" "port 53" \
    | sed "s/.*:\ \(.*\)/\1/"
}


## Tor Functions
#  SSH over Tor Socks proxy.
function torssh() {
  ssh -o ProxyCommand="nc -x localhost:9050 %h %p" ${@}
}

#  Curl via Tor Socks5h.
#  The socks5h protocol forwards DNS requests through Tor
function torcurl() {
  curl --proxy "socks5h://localhost:9050" ${@}
}
