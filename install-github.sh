#!/usr/bin/env zsh

#  Github repository url
local GITHUB_URL="https://github.com/luciferavada/satan-shell.git"

#  Git clone destination directory
local INSTALL_DIRECTORY="${HOME}/.satan-shell"

#  Clone the repository
git clone "${GITHUB_URL}" "${INSTALL_DIRECTORY}"

#  Move into the cloned repository
cd "${INSTALL_DIRECTORY}"

#  Run the install script
source "./install.sh"
