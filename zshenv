if [ -z "${HISTFILE}" ]; then
  export HISTFILE="${HOME}/.zhistory"
fi

autoload -Uz compinit promptinit

compinit
promptinit

#  man zshoptions
setopt nullglob

setopt auto_pushd
setopt pushd_ignore_dups

setopt append_history
setopt hist_verify
setopt hist_ignore_dups
setopt inc_append_history
setopt share_history

zstyle ':completion:*' menu select

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

local STATUS="%(?:%F{green}%B➜%b%f :%F{red}%B➜%b%f )"
local DIRECTORY="%F{cyan}%B%c%b%f "

export PROMPT="${STATUS} ${DIRECTORY}"
