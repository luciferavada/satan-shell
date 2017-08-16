#!/usr/bin/env zsh

#  Github repository url
local GITHUB_URL="https://github.com/luciferavada/zshell-configuration.git"

#  Git clone destination directory
local INSTALL_DIRECTORY="${HOME}/.zshell-configuration"

#  Clone the repository
git clone "${GITHUB_URL}" "${INSTALL_DIRECTORY}"

#  Move into the cloned repository
cd "${INSTALL_DIRECTORY}"

#  Run the install script
exec "./install.sh"
