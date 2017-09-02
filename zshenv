#  Do not modify this file

#  Create color associative array
local -A COLOR=(
  [black]="0"
  [red]="1"
  [green]="2"
  [yellow]="3"
  [blue]="4"
  [magenta]="5"
  [cyan]="6"
  [white]="7"
)

#  Check for 256 color support
if [ "${TERM}" = "xterm-256color" ]; then
  COLOR=(
    [black]="0"
    [red]="1"
    [green]="2"
    [yellow]="3"
    [blue]="4"
    [magenta]="5"
    [cyan]="6"
    [white]="7"
  )
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
