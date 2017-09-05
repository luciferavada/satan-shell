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

autoload -Uz compinit promptinit

compinit
promptinit

#  man zshoptions
setopt null_glob

setopt auto_pushd
setopt pushd_ignore_dups

setopt inc_append_history_time
setopt extended_history
setopt hist_verify
setopt hist_ignore_dups

setopt prompt_subst

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
