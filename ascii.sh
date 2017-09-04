#!/usr/bin/env zsh

#  Set color to red
echo -n "$(tput ${COLOR[reset]}; tput setaf ${COLOR[red]})\n"

#  Display ascii-art
cat "${PWD}/ascii-art"

#  Set color to bold red
echo -n "$(tput bold; tput setaf ${COLOR[red]})\n"

#  Display ascii-title
cat "${PWD}/ascii-title"

#  Reset display colors
echo "$(tput setaf ${COLOR[reset]})"
