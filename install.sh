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

  echo "#  User repositories" >> "${SATAN_RC}"
  echo "SATAN_USER_REPOSITORIES=()" >> "${SATAN_RC}"
  echo "" >> "${SATAN_RC}"

  echo "#  User repositories" >> "${SATAN_RC}"
  echo "SATAN_ORGANIZATION_REPOSITORIES=()" >> "${SATAN_RC}"
  echo "" >> "${SATAN_RC}"
fi

#  Write default modules file
if [ ! -f "${SATAN_MODULES}" ]; then
  echo "#  Modules are loaded in order" > "${SATAN_MODULES}"
  echo "MODULES=(" >> "${SATAN_MODULES}"
  echo "  \"prompt\" \"history\" \"man\" \"ls\" \"git\"" >> \
    "${SATAN_MODULES}"
  echo ")" >> "${SATAN_MODULES}"
fi

#  Link files
for file in ${SATAN_FILES[@]}; do

  local SRC="${SATAN}/${file}"
  local DST="${HOME}/.${file}"

  echo "linking: ${SRC} -> ${DST}"
  ln -sfh "${SRC}" "${DST}"

done

#  Create zlogin file
if [ ! -f "${HOME}/.zlogin" ]; then
  touch "${HOME}/.zlogin"
fi

#  Source environment-load function
source "${HOME}/.zprofile"

#  Load the environment
satan-load

#  Index repositories
satan-index-all

#  Install modules
for module in ${MODULES[@]}; do
  satan-install "${module}"
done

#  Reload the environment
satan-reload
