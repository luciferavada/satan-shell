#!/usr/bin/env zsh

#  Install files
local SUGAR_FILES=(
  "zshenv" "zprofile" "zshrc" "zlogin"
)

#  Install directories
local SUGAR_DIRECTORIES=(
  "zsh.d" "zsh.d.conf" "zsh.d.modules"
)

#  Files to backup
local SUGAR_BACKUPS=()

#  Files to link
local SUGAR_LINKS=()

#  Gitkeep files
local SUGAR_GITKEEP_FILES=()

#  Directories file
local SUGAR_DIRECTORIES_FILE="${HOME}/.zsh.d/directories.conf"

#  Modules file
local SUGAR_MODULES_FILE="${HOME}/.zsh.d/modules.conf"

#  Repositories file
local SUGAR_REPOSITORIES_FILE="${HOME}/.zsh.d/repositories.conf"

#  Settings file
local SUGAR_SETTINGS_FILE="${HOME}/.zsh.d/settings.conf"

#  Zlogin file
local SUGAR_ZLOGIN_FILE="${HOME}/.zlogin"

#  Source path
local SUGAR_SHELL_SOURCE="${PWD#${HOME}/}"

#  Date stamp
local DATE_STAMP=$(date +"%Y-%m-%d_%H-%M-%S")

#  Check for files to backup
for file in ${SUGAR_FILES[@]} ${SUGAR_DIRECTORIES[@]}; do

  local FILE="${HOME}/.${file}"

  #  Don't backup links
  if [ -f "${FILE}" ] && [ ! -L "${FILE}" ]; then
    SUGAR_BACKUPS+=("${file}")
  fi

done

#  Backup files
if [ -n "${SUGAR_BACKUPS}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Backing up files..."
  echo -n "$(tput sgr0)"

  for file in ${SUGAR_BACKUPS[@]}; do

    local SRC="${HOME}/.${file}"
    local DST="${HOME}/.${file}.${DATE_STAMP}"

    echo "${SRC} -> ${DST}"
    mv "${SRC}" "${DST}"

  done
fi

#  Check for files to link
for file in ${SUGAR_FILES[@]} ${SUGAR_DIRECTORIES[@]}; do

  #  Don't link zlogin
  if [ "${file}" = "zlogin" ]; then
    continue
  fi

  local SRC="${SUGAR_SHELL_SOURCE}/${file}"
  local DST="${HOME}/.${file}"

  if [ ! "$(readlink ${DST})" = "${SRC}" ]; then
    SUGAR_LINKS+=("${file}")
  fi

done

#  Link files
if [ -n "${SUGAR_LINKS}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Linking files..."
  echo -n "$(tput sgr0)"

  for file in ${SUGAR_LINKS[@]}; do

    local SRC="${SUGAR_SHELL_SOURCE}/${file}"
    local DST="${HOME}/.${file}"

    echo "${SRC} -> ${DST}"
    ln -sf "${SRC}" "${DST}"

  done
fi

#  Check for gitkeep files to remove
for directory in ${SUGAR_DIRECTORIES[@]}; do
  local GITKEEP_FILE="${PWD}/${directory}/.gitkeep"
  if [ -f "${GITKEEP_FILE}" ]; then
    SUGAR_GITKEEP_FILES+=(${GITKEEP_FILE})
  fi
done

#  Remove gitkeep files
if [ -n "${SUGAR_GITKEEP_FILES}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Removing .gitkeep files..."
  echo -n "$(tput sgr0)"

  for file in ${SUGAR_GITKEEP_FILES[@]}; do
    echo "${file}"
    git update-index --assume-unchanged "${file}"
    rm -f "${file}"
  done
fi

#  Write default directories file
if [ ! -f "${SUGAR_DIRECTORIES_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/directories.conf..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "#  Install dircetory" > "${SUGAR_DIRECTORIES_FILE}"
  echo "SUGAR_INSTALL_DIRECTORY=\"${PWD}\"" >> "${SUGAR_DIRECTORIES_FILE}"
  echo "" >> "${SUGAR_DIRECTORIES_FILE}"

  echo "#  Configuration directory" >> "${SUGAR_DIRECTORIES_FILE}"
  echo "SUGAR_CONFIGURATION_DIRECTORY=\"${HOME}/.zsh.d.conf\"" >> \
    "${SUGAR_DIRECTORIES_FILE}"
  echo "" >> "${SUGAR_DIRECTORIES_FILE}"

  echo "#  Modules directory" >> "${SUGAR_DIRECTORIES_FILE}"
  echo "SUGAR_MODULES_DIRECTORY=\"${HOME}/.zsh.d.modules\"" >> \
    "${SUGAR_DIRECTORIES_FILE}"
fi

#  Write default modules file
if [ ! -f "${SUGAR_MODULES_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/modules.conf..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "#  Modules are loaded in order" > "${SUGAR_MODULES_FILE}"
  echo "SUGAR_MODULES=(" >> "${SUGAR_MODULES_FILE}"
  echo "  \"prompt\" \"history\" \"man\" \"ls\" \"cd\" \"git\" \"ssh\"" >> \
    "${SUGAR_MODULES_FILE}"
  echo ")" >> "${SUGAR_MODULES_FILE}"
fi

#  Write default repositories file
if [ ! -f "${SUGAR_REPOSITORIES_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/repositories.conf..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "#  Repositories are indexed in order" > "${SUGAR_REPOSITORIES_FILE}"
  echo "SUGAR_REPOSITORIES=(" >> "${SUGAR_REPOSITORIES_FILE}"
  echo "  \"sugar-core\" \"sugar-extra\" \"sugar-community\"" >> \
    "${SUGAR_REPOSITORIES_FILE}"
  echo ")" >> "${SUGAR_REPOSITORIES_FILE}"
fi

#  Wride default settings file
if [ ! -f "${SUGAR_SETTINGS_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/settings.conf..."
  echo -n "$(tput sgr0)"

  echo "#  Automatic updates" > "${SUGAR_SETTINGS_FILE}"
  echo "SUGAR_AUTO_UPDATE=\"true\"" >> "${SUGAR_SETTINGS_FILE}"
  echo "" >> "${SUGAR_SETTINGS_FILE}"

  echo "#  Check weekly for updates (seconds)" >> "${SUGAR_SETTINGS_FILE}"
  echo "SUGAR_AUTO_UPDATE_CHECK=\"604800\"" >> "${SUGAR_SETTINGS_FILE}"
  echo "" >> "${SUGAR_SETTINGS_FILE}"

  echo "#  Index lock file expiration (seconds)" >> "${SUGAR_SETTINGS_FILE}"
  echo "SUGAR_INDEX_LOCK_FILE_EXPIRE=\"300\"" >> "${SUGAR_SETTINGS_FILE}"
  echo "" >> "${SUGAR_SETTINGS_FILE}"

  echo "#  Display lock expiration wait" >> "${SUGAR_SETTINGS_FILE}"
  echo "SUGAR_DISPLAY_INDEX_LOCK_FILE_WAIT=\"true\"" >> \
    "${SUGAR_SETTINGS_FILE}"
  echo "" >> "${SUGAR_SETTINGS_FILE}"

  echo "#  Display lock expiration wait every n seconds" >> \
    "${SUGAR_SETTINGS_FILE}"
  echo "SUGAR_DISPLAY_INDEX_LOCK_FILE_EVERY=\"10\"" >> \
    "${SUGAR_SETTINGS_FILE}"
  echo "" >> "${SUGAR_SETTINGS_FILE}"

  echo "#  Display ascii art" >> "${SUGAR_SETTINGS_FILE}"
  echo "SUGAR_DISPLAY_ASCII_ART=\"true\"" >> "${SUGAR_SETTINGS_FILE}"
  echo "" >> "${SUGAR_SETTINGS_FILE}"

  echo "#  Display ascii title" >> "${SUGAR_SETTINGS_FILE}"
  echo "SUGAR_DISPLAY_ASCII_TITLE=\"true\"" >> "${SUGAR_SETTINGS_FILE}"
  echo "" >> "${SUGAR_SETTINGS_FILE}"

  echo "#  Display loaded modules" >> "${SUGAR_SETTINGS_FILE}"
  echo "SUGAR_DISPLAY_MODULE_LOAD=\"true\"" >> "${SUGAR_SETTINGS_FILE}"
fi

#  Write default zlogin file
if [ ! -f "${SUGAR_ZLOGIN_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zlogin..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "## User customization goes here" > "${SUGAR_ZLOGIN_FILE}"
fi

#  Load the environment
source "${HOME}/.zshenv"
source "${HOME}/.zprofile"
source "${HOME}/.zshrc"
source "${HOME}/.zlogin"
