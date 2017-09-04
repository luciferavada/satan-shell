#!/usr/bin/env zsh

#  Set color to red
echo -n "$(tput sgr0; tput bold; tput setaf 0)\n"

#  Display ascii-art
cat "${PWD}/ascii-art"

#  Set color to bold red
echo -n "$(tput bold; tput setaf 1)\n"

#  Display ascii-title
cat "${PWD}/ascii-title"

#  Reset display colors
echo "$(tput setaf sgr0)"
