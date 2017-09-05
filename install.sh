#!/usr/bin/env zsh

#  Install files
local SATAN_FILES=(
  "zshenv" "zprofile" "zshrc" "zlogin"
  "zsh.d" "zsh.d.conf" "zsh.d.modules"
)

#  Files to backup
local SATAN_FILES_BACKUPS=()

#  Files to link
local SATAN_FILES_LINKS=()

#  Link source path
local SATAN_SHELL_SOURCE="${PWD#${HOME}/}"

#  Modules file
local SATAN_MODULES_FILE="${HOME}/.zsh.d/modules.conf"

#  Repositories file
local SATAN_REPOSITORIES_FILE="${HOME}/.zsh.d/repositories.conf"

#  Variables file
local SATAN_VARIABLES_FILE="${HOME}/.zsh.d/variables.conf"

#  Zlogin file
local SATAN_ZLOGIN_FILE="${HOME}/.zlogin"

#  Date stamp
local DATE_STAMP=$(date +"%Y-%m-%d_%H-%M-%S")

#  Check for files to backup
for file in ${SATAN_FILES[@]}; do

  local FILE="${HOME}/.${file}"

  #  Don't backup links
  if [ -f "${FILE}" ] && [ ! -L "${FILE}" ]; then
    SATAN_FILES_BACKUPS+=("${file}")
  fi

done

#  Backup files
if [ -n "${SATAN_FILES_BACKUPS}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Backing up files..."
  echo -n "$(tput sgr0)"

  for file in ${SATAN_FILES_BACKUPS[@]}; do

    local SRC="${HOME}/.${file}"
    local DST="${HOME}/.${file}.${DATE_STAMP}"

    echo "${SRC} -> ${DST}"
    mv "${SRC}" "${DST}"

  done
fi

#  Check for files to link
for file in ${SATAN_FILES[@]}; do

  #  Don't link zlogin
  if [ "${file}" = "zlogin" ]; then
    continue
  fi

  local SRC="${SATAN_SHELL_SOURCE}/${file}"
  local DST="${HOME}/.${file}"

  if [ ! "$(readlink ${DST})" = "${SRC}" ]; then
    SATAN_FILES_LINKS+=("${file}")
  fi

done

#  Link files
if [ -n "${SATAN_FILES_LINKS}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Linking files..."
  echo -n "$(tput sgr0)"

  for file in ${SATAN_FILES_LINKS[@]}; do

    local SRC="${SATAN_SHELL_SOURCE}/${file}"
    local DST="${HOME}/.${file}"

    echo "${SRC} -> ${DST}"
    ln -sfh "${SRC}" "${DST}"

  done
fi

#  Write default modules file
if [ ! -f "${SATAN_MODULES_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/modules.conf..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "#  Modules are loaded in order" > "${SATAN_MODULES_FILE}"
  echo "SATAN_MODULES=(" >> "${SATAN_MODULES_FILE}"
  echo "  \"prompt\" \"history\" \"man\" \"ls\" \"git\"" >> \
    "${SATAN_MODULES_FILE}"
  echo ")" >> "${SATAN_MODULES_FILE}"
fi

#  Write default repositories file
if [ ! -f "${SATAN_REPOSITORIES_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/repositories.conf..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "#  Repositories are indexed in order" > "${SATAN_REPOSITORIES_FILE}"
  echo "SATAN_REPOSITORIES=(" >> "${SATAN_REPOSITORIES_FILE}"
  echo "  \"satan-core\" \"satan-extra\" \"satan-community\"" >> \
    "${SATAN_REPOSITORIES_FILE}"
  echo ")" >> "${SATAN_REPOSITORIES_FILE}"

fi

#  Write default variables file
if [ ! -f "${SATAN_VARIABLES_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/rc.conf..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "#  Install dircetory" > "${SATAN_VARIABLES_FILE}"
  echo "SATAN_INSTALL_DIRECTORY=\"${PWD}\"" >> "${SATAN_VARIABLES_FILE}"
  echo "" >> "${SATAN_VARIABLES_FILE}"

  echo "#  Configuration directory" >> "${SATAN_VARIABLES_FILE}"
  echo "SATAN_CONFIGURATION_DIRECTORY=\"${HOME}/.zsh.d.conf\"" >> \
    "${SATAN_VARIABLES_FILE}"
  echo "" >> "${SATAN_VARIABLES_FILE}"

  echo "#  Modules directory" >> "${SATAN_VARIABLES_FILE}"
  echo "SATAN_MODULES_DIRECTORY=\"${HOME}/.zsh.d.modules\"" >> \
    "${SATAN_VARIABLES_FILE}"
  echo "" >> "${SATAN_VARIABLES_FILE}"
fi

#  Write default zlogin file
if [ ! -f "${SATAN_ZLOGIN_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zlogin..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "## User customization goes here" > "${SATAN_ZLOGIN_FILE}"
  echo "" >> "${SATAN_ZLOGIN_FILE}"

  echo "#  Display ascii artwork with title and credit" >> \
    "${SATAN_ZLOGIN_FILE}"
  echo "satan-ascii-header" >> "${SATAN_ZLOGIN_FILE}"
  echo "" >> "${SATAN_ZLOGIN_FILE}"

  echo "#  Display ascii artwork" >> "${SATAN_ZLOGIN_FILE}"
  echo "#satan-ascii-art" >> "${SATAN_ZLOGIN_FILE}"
  echo "" >> "${SATAN_ZLOGIN_FILE}"

  echo "#  Display credit" >> "${SATAN_ZLOGIN_FILE}"
  echo "#satan-credit" >> "${SATAN_ZLOGIN_FILE}"
  echo "" >> "${SATAN_ZLOGIN_FILE}"

  echo "#  Display ascii title" >> "${SATAN_ZLOGIN_FILE}"
  echo "#satan-ascii-title" >> "${SATAN_ZLOGIN_FILE}"
fi

#  Remove and ignore gitkeep files
for files in ${SATAN_FILES[@]}; do
  if [ -d "${file}" ]; then
    local GITKEEP="${HOME}/.${file}/.gitkeep"
    if [ -f "${GITKEEP}" ]; then
      git update-index --assume-unchanged "${GITKEEP}"
      rm -f "${GITKEEP}"
    fi
  fi
done

#  Load the environment
source "${HOME}/.zshenv"
source "${HOME}/.zprofile"
source "${HOME}/.zshrc"
source "${HOME}/.zlogin"
