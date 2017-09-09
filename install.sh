#!/usr/bin/env zsh

#  Install files
local SATAN_FILES=(
  "zshenv" "zprofile" "zshrc" "zlogin"
)

#  Install directories
local SATAN_DIRECTORIES=(
  "zsh.d" "zsh.d.conf" "zsh.d.modules"
)

#  Files to backup
local SATAN_BACKUPS=()

#  Files to link
local SATAN_LINKS=()

#  Gitkeep files
local SATAN_GITKEEP_FILES=()

#  Directories file
local SATAN_DIRECTORIES_FILE="${HOME}/.zsh.d/directories.conf"

#  Modules file
local SATAN_MODULES_FILE="${HOME}/.zsh.d/modules.conf"

#  Repositories file
local SATAN_REPOSITORIES_FILE="${HOME}/.zsh.d/repositories.conf"

#  Settings file
local SATAN_SETTINGS_FILE="${HOME}/.zsh.d/settings.conf"

#  Zlogin file
local SATAN_ZLOGIN_FILE="${HOME}/.zlogin"

#  Link source path
local SATAN_SHELL_SOURCE="${PWD#${HOME}/}"

#  Date stamp
local DATE_STAMP=$(date +"%Y-%m-%d_%H-%M-%S")

#  Check for files to backup
for file in ${SATAN_FILES[@]} ${SATAN_DIRECTORIES[@]}; do

  local FILE="${HOME}/.${file}"

  #  Don't backup links
  if [ -f "${FILE}" ] && [ ! -L "${FILE}" ]; then
    SATAN_BACKUPS+=("${file}")
  fi

done

#  Backup files
if [ -n "${SATAN_BACKUPS}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Backing up files..."
  echo -n "$(tput sgr0)"

  for file in ${SATAN_BACKUPS[@]}; do

    local SRC="${HOME}/.${file}"
    local DST="${HOME}/.${file}.${DATE_STAMP}"

    echo "${SRC} -> ${DST}"
    mv "${SRC}" "${DST}"

  done
fi

#  Check for files to link
for file in ${SATAN_FILES[@]} ${SATAN_DIRECTORIES[@]}; do

  #  Don't link zlogin
  if [ "${file}" = "zlogin" ]; then
    continue
  fi

  local SRC="${SATAN_SHELL_SOURCE}/${file}"
  local DST="${HOME}/.${file}"

  if [ ! "$(readlink ${DST})" = "${SRC}" ]; then
    SATAN_LINKS+=("${file}")
  fi

done

#  Link files
if [ -n "${SATAN_LINKS}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Linking files..."
  echo -n "$(tput sgr0)"

  for file in ${SATAN_LINKS[@]}; do

    local SRC="${SATAN_SHELL_SOURCE}/${file}"
    local DST="${HOME}/.${file}"

    echo "${SRC} -> ${DST}"
    ln -sfh "${SRC}" "${DST}"

  done
fi

#  Check for gitkeep files to remove
for directory in ${SATAN_DIRECTORIES[@]}; do
  local GITKEEP_FILE="${PWD}/${directory}/.gitkeep"
  if [ -f "${GITKEEP_FILE}" ]; then
    SATAN_GITKEEP_FILES+=(${GITKEEP_FILE})
  fi
done

#  Remove gitkeep files
if [ -n "${SATAN_GITKEEP_FILES}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Removing .gitkeep files..."
  echo -n "$(tput sgr0)"

  for file in ${SATAN_GITKEEP_FILES[@]}; do
    echo "${file}"
    git update-index --assume-unchanged "${file}"
    rm -f "${file}"
  done
fi

#  Write default directories file
if [ ! -f "${SATAN_DIRECTORIES_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/directories.conf..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "#  Install dircetory" > "${SATAN_DIRECTORIES_FILE}"
  echo "SATAN_INSTALL_DIRECTORY=\"${PWD}\"" >> "${SATAN_DIRECTORIES_FILE}"
  echo "" >> "${SATAN_DIRECTORIES_FILE}"

  echo "#  Configuration directory" >> "${SATAN_DIRECTORIES_FILE}"
  echo "SATAN_CONFIGURATION_DIRECTORY=\"${HOME}/.zsh.d.conf\"" >> \
    "${SATAN_DIRECTORIES_FILE}"
  echo "" >> "${SATAN_DIRECTORIES_FILE}"

  echo "#  Modules directory" >> "${SATAN_DIRECTORIES_FILE}"
  echo "SATAN_MODULES_DIRECTORY=\"${HOME}/.zsh.d.modules\"" >> \
    "${SATAN_DIRECTORIES_FILE}"
  echo "" >> "${SATAN_DIRECTORIES_FILE}"
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

#  Wride default settings file
if [ ! -f "${SATAN_SETTINGS_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zsh.d/settings.conf..."
  echo -n "$(tput sgr0)"

  echo "#  Automatically update modules" > "${SATAN_SETTINGS_FILE}"
  echo "SATAN_AUTO_UPDATE=\"true\"" >> "${SATAN_SETTINGS_FILE}"
  echo "" >> "${SATAN_SETTINGS_FILE}"

  echo "#  Display ascii art" >> "${SATAN_SETTINGS_FILE}"
  echo "SATAN_DISPLAY_ASCII_ART=\"true\"" >> "${SATAN_SETTINGS_FILE}"
  echo "" >> "${SATAN_SETTINGS_FILE}"

  echo "#  Display ascii title" >> "${SATAN_SETTINGS_FILE}"
  echo "SATAN_DISPLAY_ASCII_TITLE=\"true\"" >> "${SATAN_SETTINGS_FILE}"
  echo "" >> "${SATAN_SETTINGS_FILE}"

  echo "#  Display loaded modules" >> "${SATAN_SETTINGS_FILE}"
  echo "SATAN_DISPLAY_MODULE_LOAD=\"true\"" >> "${SATAN_SETTINGS_FILE}"
  echo "" >> "${SATAN_SETTINGS_FILE}"

  echo "#  Display documentation with Markdown Viewer" >> \
    "${SATAN_SETTINGS_FILE}"
  echo "SATAN_USE_MARKDOWN_VIEWER=\"true\"" >> "${SATAN_SETTINGS_FILE}"
  echo "" >> "${SATAN_SETTINGS_FILE}"

  echo "#  Markdown Viewer (mdv) theme" >> "${SATAN_SETTINGS_FILE}"
  echo "SATAN_MARKDOWN_VIEWER_THEME=\"960.847\"" >> "${SATAN_SETTINGS_FILE}"
  echo "" >> "${SATAN_SETTINGS_FILE}"
fi

#  Write default zlogin file
if [ ! -f "${SATAN_ZLOGIN_FILE}" ]; then
  #  Colorized output
  echo -n "$(tput bold; tput setaf 2)"
  echo "--> Writing default ~/.zlogin..."
  echo -n "$(tput sgr0)"

  #  Write file
  echo "## User customization goes here" > "${SATAN_ZLOGIN_FILE}"
fi

#  Load the environment
source "${HOME}/.zshenv"
source "${HOME}/.zprofile"
source "${HOME}/.zshrc"
source "${HOME}/.zlogin"
