#!/usr/bin/env zsh

#  Github repository url
local GITHUB_URL="https://github.com/lucifersears/satan-shell.git"

#  Git clone destination directory
local INSTALL_DIRECTORY="${HOME}/.satan-shell"

#  Colorize output
echo -n "$(tput bold; tput setaf 2)"
echo "--> Installing satan-shell..."
echo -n "$(tput sgr0)"

#  Clone the repository
git clone "${GITHUB_URL}" "${INSTALL_DIRECTORY}"

#  Move into the cloned repository
cd "${INSTALL_DIRECTORY}"

#  Run the install script
source "./install.sh"

#  Move to the home directory
cd "${HOME}"
