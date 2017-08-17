autoload -Uz compinit promptinit

compinit
promptinit

#  man zshoptions
setopt nullglob

setopt auto_pushd
setopt pushd_ignore_dups

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
