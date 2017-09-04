#!/usr/bin/env zsh

#  Github repository url
local GITHUB_URL="https://github.com/luciferavada/satan-shell.git"

#  Git clone destination directory
local INSTALL_DIRECTORY="${HOME}/.satan-shell"

#  Colorize output
echo -n "$(tput bold; tput setaf 7)"
echo "--> Installing satan-shell..."
echo -n "$(tput setaf 6)"

#  Clone the repository
git clone "${GITHUB_URL}" "${INSTALL_DIRECTORY}"

#  Reset colors
echo -n "$(tput sgr0)"

#  Move into the cloned repository
cd "${INSTALL_DIRECTORY}"

#  Run the install script
source "./install.sh"
