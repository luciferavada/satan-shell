#!/usr/bin/env zsh

#  Install files
local CANDY_FILES=(
  "zshenv" "zshrc" "zuser"
)

#  Install directories
local CANDY_DIRECTORIES=(
  "zsh.d" "zsh.d.conf" "zsh.d.modules"
)

#  Files to backup
local CANDY_BACKUPS=()

#  Files to link
local CANDY_LINKS=()

#  Gitkeep files
local CANDY_GITKEEP_FILES=()

#  Directories file
local CANDY_DIRECTORIES_FILE="${HOME}/.zsh.d/directories.conf"

#  Modules file
local CANDY_MODULES_FILE="${HOME}/.zsh.d/modules.conf"

#  Repositories file
local CANDY_REPOSITORIES_FILE="${HOME}/.zsh.d/repositories.conf"

#  Settings file
local CANDY_SETTINGS_FILE="${HOME}/.zsh.d/settings.conf"

#  Zlogin file
local CANDY_ZUSER_FILE="${HOME}/.zuser"

#  Source path
local CANDY_SOURCE="${PWD#${HOME}/}"

#  Date stamp
local DATE_STAMP=$(date +"%Y-%m-%d_%H-%M-%S")

#  Check for files to backup
for file in ${CANDY_FILES[@]} ${CANDY_DIRECTORIES[@]}; do

  local FILE="${HOME}/.${file}"

  #  Don't backup links
  if [ -f "${FILE}" ] && [ ! -L "${FILE}" ]; then
    CANDY_BACKUPS+=("${file}")
  fi

done

#  Backup files
if [ -n "${CANDY_BACKUPS}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Backing up files..."
  echo -n "$(tput sgr0)"

  for file in ${CANDY_BACKUPS[@]}; do

    local SRC="${HOME}/.${file}"
    local DST="${HOME}/.${file}.${DATE_STAMP}"

    echo "${SRC} -> ${DST}"
    mv "${SRC}" "${DST}"

  done
fi

#  Check for files to link
for file in ${CANDY_FILES[@]} ${CANDY_DIRECTORIES[@]}; do

  #  Don't link zuser
  if [ "${file}" = "zuser" ]; then
    continue
  fi

  local SRC="${CANDY_SOURCE}/${file}"
  local DST="${HOME}/.${file}"

  if [ ! "$(readlink ${DST})" = "${SRC}" ]; then
    CANDY_LINKS+=("${file}")
  fi

done

#  Link files
if [ -n "${CANDY_LINKS}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Linking files..."
  echo -n "$(tput sgr0)"

  for file in ${CANDY_LINKS[@]}; do

    local SRC="${CANDY_SOURCE}/${file}"
    local DST="${HOME}/.${file}"

    echo "${SRC} -> ${DST}"
    ln -sf "${SRC}" "${DST}"

  done
fi

#  Check for gitkeep files to remove
for directory in ${CANDY_DIRECTORIES[@]}; do
  local GITKEEP_FILE="${PWD}/${directory}/.gitkeep"
  if [ -f "${GITKEEP_FILE}" ]; then
    CANDY_GITKEEP_FILES+=(${GITKEEP_FILE})
  fi
done

#  Remove gitkeep files
if [ -n "${CANDY_GITKEEP_FILES}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Removing .gitkeep files..."
  echo -n "$(tput sgr0)"

  for file in ${CANDY_GITKEEP_FILES[@]}; do
    echo "${file}"
    git update-index --assume-unchanged "${file}"
    rm -f "${file}"
  done
fi

#  Write default directories file
if [ ! -f "${CANDY_DIRECTORIES_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/directories.conf..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "#  Install dircetory" > "${CANDY_DIRECTORIES_FILE}"
  echo "CANDY_INSTALL_DIRECTORY=\"${PWD}\"" >> "${CANDY_DIRECTORIES_FILE}"
  echo "" >> "${CANDY_DIRECTORIES_FILE}"

  echo "#  Configuration directory" >> "${CANDY_DIRECTORIES_FILE}"
  echo "CANDY_CONFIGURATION_DIRECTORY=\"${HOME}/.zsh.d.conf\"" >> \
    "${CANDY_DIRECTORIES_FILE}"
  echo "" >> "${CANDY_DIRECTORIES_FILE}"

  echo "#  Modules directory" >> "${CANDY_DIRECTORIES_FILE}"
  echo "CANDY_MODULES_DIRECTORY=\"${HOME}/.zsh.d.modules\"" >> \
    "${CANDY_DIRECTORIES_FILE}"
fi

#  Write default modules file
if [ ! -f "${CANDY_MODULES_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/modules.conf..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "#  Modules are loaded in order" > "${CANDY_MODULES_FILE}"
  echo "CANDY_MODULES=(" >> "${CANDY_MODULES_FILE}"
  echo "  \"prompt\" \"syntax\" \"history\" \"path\" \"man\" \"ls\" \"cd\" \"git\" \"ssh\"" >> \
    "${CANDY_MODULES_FILE}"
  echo ")" >> "${CANDY_MODULES_FILE}"
fi

#  Write default repositories file
if [ ! -f "${CANDY_REPOSITORIES_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/repositories.conf..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "#  Repositories are indexed in order" > "${CANDY_REPOSITORIES_FILE}"
  echo "CANDY_REPOSITORIES=(" >> "${CANDY_REPOSITORIES_FILE}"
  echo "  \"candy-core\" \"candy-extra\" " >> \
    "${CANDY_REPOSITORIES_FILE}"
  echo ")" >> "${CANDY_REPOSITORIES_FILE}"
fi

#  Wride default settings file
if [ ! -f "${CANDY_SETTINGS_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/settings.conf..."
  echo -n "$(tput sgr0)"

  echo "#  Automatic updates" > "${CANDY_SETTINGS_FILE}"
  echo "CANDY_AUTO_UPDATE=\"false\"" >> "${CANDY_SETTINGS_FILE}"
  echo "" >> "${CANDY_SETTINGS_FILE}"

  echo "#  Check weekly for updates (seconds)" >> "${CANDY_SETTINGS_FILE}"
  echo "CANDY_AUTO_UPDATE_CHECK=\"604800\"" >> "${CANDY_SETTINGS_FILE}"
  echo "" >> "${CANDY_SETTINGS_FILE}"

  echo "#  Index lock file check (seconds)" >> "${CANDY_SETTINGS_FILE}"
  echo "CANDY_INDEX_LOCK_FILE_CHECK=\"1\"" >> "${CANDY_SETTINGS_FILE}"
  echo "" >> "${CANDY_SETTINGS_FILE}"

  echo "#  Index lock file expiration (seconds)" >> "${CANDY_SETTINGS_FILE}"
  echo "CANDY_INDEX_LOCK_FILE_EXPIRE=\"300\"" >> "${CANDY_SETTINGS_FILE}"
  echo "" >> "${CANDY_SETTINGS_FILE}"

  echo "#  Display ascii art" >> "${CANDY_SETTINGS_FILE}"
  echo "CANDY_DISPLAY_ASCII_ART=\"true\"" >> "${CANDY_SETTINGS_FILE}"
  echo "" >> "${CANDY_SETTINGS_FILE}"

  echo "#  Display ascii title" >> "${CANDY_SETTINGS_FILE}"
  echo "CANDY_DISPLAY_ASCII_TITLE=\"true\"" >> "${CANDY_SETTINGS_FILE}"
  echo "" >> "${CANDY_SETTINGS_FILE}"

  echo "#  Display loaded modules" >> "${CANDY_SETTINGS_FILE}"
  echo "CANDY_DISPLAY_MODULE_LOAD=\"true\"" >> "${CANDY_SETTINGS_FILE}"
fi

#  Write default zuser file
if [ ! -f "${CANDY_ZUSER_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zuser..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "## User customization goes here" > "${CANDY_ZUSER_FILE}"
fi

#  Load the environment
source "${HOME}/.zshenv"
source "${HOME}/.zshrc"
