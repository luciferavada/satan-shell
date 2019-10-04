#!/usr/bin/env zsh

#  Install files
local SANTA_FILES=(
  "zshenv" "zshrc" "zuser"
)

#  Install directories
local SANTA_DIRECTORIES=(
  "zsh.d" "zsh.d.conf" "zsh.d.modules"
)

#  Files to backup
local SANTA_BACKUPS=()

#  Files to link
local SANTA_LINKS=()

#  Gitkeep files
local SANTA_GITKEEP_FILES=()

#  Directories file
local SANTA_DIRECTORIES_FILE="${HOME}/.zsh.d/directories.conf"

#  Modules file
local SANTA_MODULES_FILE="${HOME}/.zsh.d/modules.conf"

#  Repositories file
local SANTA_REPOSITORIES_FILE="${HOME}/.zsh.d/repositories.conf"

#  Settings file
local SANTA_SETTINGS_FILE="${HOME}/.zsh.d/settings.conf"

#  Zlogin file
local SANTA_ZUSER_FILE="${HOME}/.zuser"

#  Source path
local SANTA_SHELL_SOURCE="${PWD#${HOME}/}"

#  Date stamp
local DATE_STAMP=$(date +"%Y-%m-%d_%H-%M-%S")

#  Check for files to backup
for file in ${SANTA_FILES[@]} ${SANTA_DIRECTORIES[@]}; do

  local FILE="${HOME}/.${file}"

  #  Don't backup links
  if [ -f "${FILE}" ] && [ ! -L "${FILE}" ]; then
    SANTA_BACKUPS+=("${file}")
  fi

done

#  Backup files
if [ -n "${SANTA_BACKUPS}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Backing up files..."
  echo -n "$(tput sgr0)"

  for file in ${SANTA_BACKUPS[@]}; do

    local SRC="${HOME}/.${file}"
    local DST="${HOME}/.${file}.${DATE_STAMP}"

    echo "${SRC} -> ${DST}"
    mv "${SRC}" "${DST}"

  done
fi

#  Check for files to link
for file in ${SANTA_FILES[@]} ${SANTA_DIRECTORIES[@]}; do

  #  Don't link zuser
  if [ "${file}" = "zuser" ]; then
    continue
  fi

  local SRC="${SANTA_SHELL_SOURCE}/${file}"
  local DST="${HOME}/.${file}"

  if [ ! "$(readlink ${DST})" = "${SRC}" ]; then
    SANTA_LINKS+=("${file}")
  fi

done

#  Link files
if [ -n "${SANTA_LINKS}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Linking files..."
  echo -n "$(tput sgr0)"

  for file in ${SANTA_LINKS[@]}; do

    local SRC="${SANTA_SHELL_SOURCE}/${file}"
    local DST="${HOME}/.${file}"

    echo "${SRC} -> ${DST}"
    ln -sf "${SRC}" "${DST}"

  done
fi

#  Check for gitkeep files to remove
for directory in ${SANTA_DIRECTORIES[@]}; do
  local GITKEEP_FILE="${PWD}/${directory}/.gitkeep"
  if [ -f "${GITKEEP_FILE}" ]; then
    SANTA_GITKEEP_FILES+=(${GITKEEP_FILE})
  fi
done

#  Remove gitkeep files
if [ -n "${SANTA_GITKEEP_FILES}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Removing .gitkeep files..."
  echo -n "$(tput sgr0)"

  for file in ${SANTA_GITKEEP_FILES[@]}; do
    echo "${file}"
    git update-index --assume-unchanged "${file}"
    rm -f "${file}"
  done
fi

#  Write default directories file
if [ ! -f "${SANTA_DIRECTORIES_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/directories.conf..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "#  Install dircetory" > "${SANTA_DIRECTORIES_FILE}"
  echo "SANTA_INSTALL_DIRECTORY=\"${PWD}\"" >> "${SANTA_DIRECTORIES_FILE}"
  echo "" >> "${SANTA_DIRECTORIES_FILE}"

  echo "#  Configuration directory" >> "${SANTA_DIRECTORIES_FILE}"
  echo "SANTA_CONFIGURATION_DIRECTORY=\"${HOME}/.zsh.d.conf\"" >> \
    "${SANTA_DIRECTORIES_FILE}"
  echo "" >> "${SANTA_DIRECTORIES_FILE}"

  echo "#  Modules directory" >> "${SANTA_DIRECTORIES_FILE}"
  echo "SANTA_MODULES_DIRECTORY=\"${HOME}/.zsh.d.modules\"" >> \
    "${SANTA_DIRECTORIES_FILE}"
fi

#  Write default modules file
if [ ! -f "${SANTA_MODULES_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/modules.conf..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "#  Modules are loaded in order" > "${SANTA_MODULES_FILE}"
  echo "SANTA_MODULES=(" >> "${SANTA_MODULES_FILE}"
  echo "  \"prompt\" \"history\" \"path\" \"man\" \"ls\" \"cd\" \"git\" \"ssh\"" >> \
    "${SANTA_MODULES_FILE}"
  echo ")" >> "${SANTA_MODULES_FILE}"
fi

#  Write default repositories file
if [ ! -f "${SANTA_REPOSITORIES_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/repositories.conf..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "#  Repositories are indexed in order" > "${SANTA_REPOSITORIES_FILE}"
  echo "SANTA_REPOSITORIES=(" >> "${SANTA_REPOSITORIES_FILE}"
  echo "  \"santa-core\" \"santa-extra\" \"santa-community\"" >> \
    "${SANTA_REPOSITORIES_FILE}"
  echo ")" >> "${SANTA_REPOSITORIES_FILE}"
fi

#  Wride default settings file
if [ ! -f "${SANTA_SETTINGS_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/settings.conf..."
  echo -n "$(tput sgr0)"

  echo "#  Automatic updates" > "${SANTA_SETTINGS_FILE}"
  echo "SANTA_AUTO_UPDATE=\"false\"" >> "${SANTA_SETTINGS_FILE}"
  echo "" >> "${SANTA_SETTINGS_FILE}"

  echo "#  Check weekly for updates (seconds)" >> "${SANTA_SETTINGS_FILE}"
  echo "SANTA_AUTO_UPDATE_CHECK=\"604800\"" >> "${SANTA_SETTINGS_FILE}"
  echo "" >> "${SANTA_SETTINGS_FILE}"

  echo "#  Index lock file check (seconds)" >> "${SANTA_SETTINGS_FILE}"
  echo "SANTA_INDEX_LOCK_FILE_CHECK=\"1\"" >> "${SANTA_SETTINGS_FILE}"
  echo "" >> "${SANTA_SETTINGS_FILE}"

  echo "#  Index lock file expiration (seconds)" >> "${SANTA_SETTINGS_FILE}"
  echo "SANTA_INDEX_LOCK_FILE_EXPIRE=\"300\"" >> "${SANTA_SETTINGS_FILE}"
  echo "" >> "${SANTA_SETTINGS_FILE}"

  echo "#  Display ascii art" >> "${SANTA_SETTINGS_FILE}"
  echo "SANTA_DISPLAY_ASCII_ART=\"true\"" >> "${SANTA_SETTINGS_FILE}"
  echo "" >> "${SANTA_SETTINGS_FILE}"

  echo "#  Display ascii title" >> "${SANTA_SETTINGS_FILE}"
  echo "SANTA_DISPLAY_ASCII_TITLE=\"true\"" >> "${SANTA_SETTINGS_FILE}"
  echo "" >> "${SANTA_SETTINGS_FILE}"

  echo "#  Display loaded modules" >> "${SANTA_SETTINGS_FILE}"
  echo "SANTA_DISPLAY_MODULE_LOAD=\"true\"" >> "${SANTA_SETTINGS_FILE}"
fi

#  Write default zuser file
if [ ! -f "${SANTA_ZUSER_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zuser..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "## User customization goes here" > "${SANTA_ZUSER_FILE}"
fi

#  Load the environment
source "${HOME}/.zshenv"
source "${HOME}/.zshrc"
