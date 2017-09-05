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

#  Colorize output
echo -n "$(tput bold; tput setaf 2)"
echo "--> Linking files..."
echo -n "$(tput sgr0; tput setaf 7)"

#  Link files
for file in ${SATAN_FILES[@]}; do

  local SRC="${SATAN}/${file}"
  local DST="${HOME}/.${file}"

  if [ -f "${DST}" ]; then
    mv "${DST}" "${DST}.back"
  fi

  echo "${SRC} -> ${DST}"
  ln -sfh "${SRC}" "${DST}"

done

#  Reset colors
echo -n "$(tput sgr0)"

#  Write default rc file
if [ ! -f "${SATAN_RC}" ]; then
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
  echo "" >> "${SATAN_RC}"
fi

#  Write default modules file
if [ ! -f "${SATAN_MODULES}" ]; then
  echo "#  Modules are loaded in order" > "${SATAN_MODULES}"
  echo "SATAN_MODULES=(" >> "${SATAN_MODULES}"
  echo "  \"prompt\" \"history\" \"man\" \"ls\" \"git\"" >> \
    "${SATAN_MODULES}"
  echo ")" >> "${SATAN_MODULES}"
fi

#  Create zlogin file
if [ ! -f "${HOME}/.zlogin" ]; then
  echo "satan-ascii-art" > "${HOME}/.zlogin"
fi

#  Load the environment
source "${HOME}/.zshenv"
source "${HOME}/.zprofile"
source "${HOME}/.zshrc"
source "${HOME}/.zlogin"

#  Move to the home directory
cd "${HOME}"
