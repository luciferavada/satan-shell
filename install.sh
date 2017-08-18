#!/usr/bin/env zsh

#  Install files
local INSTALL_FILES=(
  "zshenv" "zprofile" "zshrc"
  "zsh.d" "zsh.d.conf" "zsh.d.modules"
)

#  Link source path
local BASE="${PWD#${HOME}/}"

#  Link files
for file in ${INSTALL_FILES[@]}; do

  local SRC="${BASE}/${file}"
  local DST="${HOME}/.${file}"

  echo "linking: ${SRC} -> ${DST}"
  ln -sfh "${SRC}" "${DST}"

done

#  Modules file
local ZSHELL_MODULES_FILE="${HOME}/.zsh.d/modules.conf"

#  Write default modules file
if [ ! -f "${ZSHELL_MODULES_FILE}" ]; then
  echo "#  Modules are loaded in order" > "${ZSHELL_MODULES_FILE}"
  echo "MODULES=(" >> "${ZSHELL_MODULES_FILE}"
  echo "  \"prompt\" \"history\" \"man\" \"ls\" \"git\"" >> \
    "${ZSHELL_MODULES_FILE}"
  echo ")" >> "${ZSHELL_MODULES_FILE}"
fi

#  RC file
local ZSHELL_RC_FILE="${HOME}/.zsh.d/rc.conf"

#  Write default rc file
if [ ! -f "${ZSHELL_RC_FILE}" ]; then
  echo "#  Install dircetory" > "${ZSHELL_RC_FILE}"
  echo "ZSHELL_INSTALL_DIRECTORY=\"${PWD}\"" >> "${ZSHELL_RC_FILE}"
  echo "" >> "${ZSHELL_RC_FILE}"

  echo "#  Configuration directory" >> "${ZSHELL_RC_FILE}"
  echo "ZSHELL_CONFIGURATION_DIRECTORY=\"${HOME}/.zsh.d.conf\"" >> \
    "${ZSHELL_RC_FILE}"
  echo "" >> "${ZSHELL_RC_FILE}"

  echo "#  Modules directory" >> "${ZSHELL_RC_FILE}"
  echo "ZSHELL_MODULES_DIRECTORY=\"${HOME}/.zsh.d.modules\"" >> \
    "${ZSHELL_RC_FILE}"
fi

#  Create zlogin file
if [ ! -f "${HOME}/.zlogin" ]; then
  touch "${HOME}/.zlogin"
fi

#  Source environment-load function
source "${HOME}/.zprofile"

#  Load environment
environment-load
