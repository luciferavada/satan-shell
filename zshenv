#  Do not modify this file

#  Create color associative array
local -A COLOR

COLOR[reset]="sgr0"

COLOR[black]="0"
COLOR[red]="1"
COLOR[green]="2"
COLOR[yellow]="3"
COLOR[blue]="4"
COLOR[magenta]="5"
COLOR[cyan]="6"
COLOR[white]="7"

#  Check for 256 color support
if [ "${TERM}" = "xterm-256color" ]; then
  COLOR[black]="0"
  COLOR[red]="1"
  COLOR[green]="2"
  COLOR[yellow]="3"
  COLOR[blue]="4"
  COLOR[magenta]="5"
  COLOR[cyan]="6"
  COLOR[white]="7"
fi

autoload -Uz compinit promptinit

compinit
promptinit

#  man zshoptions
setopt nullglob

setopt auto_pushd
setopt pushd_ignore_dups

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
