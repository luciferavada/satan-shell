#!/usr/bin/env zsh

#  Install files
local SATAN_FILES=(
  "zshenv" "zprofile" "zshrc"
  "zsh.d" "zsh.d.conf" "zsh.d.modules"
)

#  RC file
local SATAN_RC="${HOME}/.zsh.d/rc.conf"

#  Modules file
local SATAN_MODULES="${HOME}/.zsh.d/modules.conf"

#  Link source path
local SATAN="${PWD#${HOME}/}"

#  Colorized output
echo -n "$(tput bold; tput setaf 2)"
echo "--> Linking files..."
echo -n "$(tput sgr0)"

#  Link files
for file in ${SATAN_FILES[@]}; do

  local SRC="${SATAN}/${file}"
  local DST="${HOME}/.${file}"

  echo "${SRC} -> ${DST}"
  ln -sfh "${SRC}" "${DST}"

done

#  Write default rc file
if [ ! -f "${SATAN_RC}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/rc.conf..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "#  Install dircetory" > "${SATAN_RC}"
  echo "SATAN_INSTALL_DIRECTORY=\"${PWD}\"" >> "${SATAN_RC}"
  echo "" >> "${SATAN_RC}"

  echo "#  Configuration directory" >> "${SATAN_RC}"
  echo "SATAN_CONFIGURATION_DIRECTORY=\"${HOME}/.zsh.d.conf\"" >> \
    "${SATAN_RC}"
  echo "" >> "${SATAN_RC}"

  echo "#  Modules directory" >> "${SATAN_RC}"
  echo "SATAN_MODULES_DIRECTORY=\"${HOME}/.zsh.d.modules\"" >> "${SATAN_RC}"
  echo "" >> "${SATAN_RC}"

  echo "#  Repositories" >> "${SATAN_RC}"
  echo "SATAN_REPOSITORIES=(" >> "${SATAN_RC}"
  echo "  \"satan-core\" \"satan-extra\" \"satan-community\"" >> "${SATAN_RC}"
  echo ")" >> "${SATAN_RC}"
fi

#  Write default modules file
if [ ! -f "${SATAN_MODULES}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/modules.conf..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "#  Modules are loaded in order" > "${SATAN_MODULES}"
  echo "SATAN_MODULES=(" >> "${SATAN_MODULES}"
  echo "  \"prompt\" \"history\" \"man\" \"ls\" \"git\"" >> \
    "${SATAN_MODULES}"
  echo ")" >> "${SATAN_MODULES}"
fi

#  Backup zlogin
if [ -f "${HOME}/.zlogin" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Backing up ~/.zlogin..."
  echo -n "$(tput sgr0)"

  #  Date stamp
  local DATE_STAMP=$(date +"%Y-%m-%d_%H-%M-%S")

  #  Add datestamp to old zlogin
  echo "~/.zlogin -> ~/.zlogin.${DATE_STAMP}"
  mv "${HOME}/.zlogin" "${HOME}/.zlogin.${DATE_STAMP}"
fi

#  Create zlogin file
if [ ! -f "${HOME}/.zlogin" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zlogin..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "## User customization goes here" > "${HOME}/.zlogin"
  echo "" >> "${HOME}/.zlogin"

  echo "#  Display ascii artwork with title and credit" >> "${HOME}/.zlogin"
  echo "#satan-ascii-header" >> "${HOME}/.zlogin"
  echo "" >> "${HOME}/.zlogin"

  echo "#  Display ascii artwork" >> "${HOME}/.zlogin"
  echo "#satan-ascii-art" >> "${HOME}/.zlogin"
  echo "" >> "${HOME}/.zlogin"

  echo "#  Display credit" >> "${HOME}/.zlogin"
  echo "satan-credit" >> "${HOME}/.zlogin"
  echo "" >> "${HOME}/.zlogin"

  echo "#  Display ascii title" >> "${HOME}/.zlogin"
  echo "satan-ascii-title" >> "${HOME}/.zlogin"
fi

#  Load the environment
source "${HOME}/.zshenv"
source "${HOME}/.zprofile"
source "${HOME}/.zshrc"

#  Display ascii art
satan-ascii-art

#  Load zlogin
source "${HOME}/.zlogin"

#  Move to the home directory
cd "${HOME}"
