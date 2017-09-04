#!/usr/bin/env zsh

#  Set color to red
echo "$(tput sgr0; tput bold; tput setaf 0)"

#  Display ascii-art
cat "${SATAN_INSTALL_DIRECTORY}/ascii-art"

#  Set color to bold red
echo "$(tput bold; tput setaf 1)"

#  Display ascii-title
cat "${SATAN_INSTALL_DIRECTORY}/ascii-title"

#  Reset display colors
echo "$(tput setaf sgr0)"
