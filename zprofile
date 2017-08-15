autoload -Uz compinit promptinit

compinit
promptinit

zstyle ':completion:*' menu select

local STATUS="%(?:%F{green}%B➜%b%f :%F{red}%B➜%b%f )"
local DIRECTORY="%F{cyan}%B%c%b%f "

export PROMPT="${STATUS} ${DIRECTORY}"
