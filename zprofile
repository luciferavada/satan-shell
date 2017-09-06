#  Do not modify this file

#  Github URL
local GITHUB_URL="https://github.com"

#  Github API URL
local GITHUB_API_URL="https://api.github.com"

#  Environment files
local SATAN_FILES=("zshenv" "zprofile" "zshrc" "zlogin")

#  Satan modules index
local SATAN_INDEX_AVAILABLE="${HOME}/.zsh.d/.index.available"

#  Satan modules installed
local SATAN_INDEX_INSTALLED="${HOME}/.zsh.d/.index.installed"

#  Satan configuration files
local SATAN_DIRECTORIES_FILE="${HOME}/.zsh.d/directories.conf"
local SATAN_MODULES_FILE="${HOME}/.zsh.d/modules.conf"
local SATAN_REPOSITORIES_FILE="${HOME}/.zsh.d/repositories.conf"
local SATAN_SETTINGS_FILE="${HOME}/.zsh.d/settings.conf"

#  Load configuration variables
function satan-load-configuration-variables \
         satan-reload-configuration-variables() {
  source "${SATAN_DIRECTORIES_FILE}"
  source "${SATAN_MODULES_FILE}"
  source "${SATAN_REPOSITORIES_FILE}"
  source "${SATAN_SETTINGS_FILE}"
}

#  Display ascii art
function satan-ascii-art() {
  echo ""
  echo -n "$(tput ${COLOR[reset]}; tput bold; tput setaf ${COLOR[black]})"
  cat "${SATAN_INSTALL_DIRECTORY}/ascii-art"
  echo ""
}

#  Display ascii title
function satan-ascii-title() {
  echo -n "$(tput bold; tput setaf ${COLOR[red]})"
  cat "${SATAN_INSTALL_DIRECTORY}/ascii-title"
  echo ""
}

#  Display credit
function satan-credit() {
  echo ""
  echo -n "$(tput ${COLOR[reset]}; tput bold; tput setaf ${COLOR[black]})"
  echo "   By: Lucifer Avada | Github: luciferavada | Twitter: @luciferavada"
  echo ""
}

#  Display ascii header
function satan-ascii-header() {
  satan-ascii-art
  satan-credit
  satan-ascii-title
}

#  Get module remote origin url
function _satan-module-get-url() {
  local MODULE_LINE="${1}"
  git -C "${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}" remote get-url origin 2> \
    /dev/null
}

#  Set module remote origin URL
function _satan-module-set-url() {
  local MODULE_LINE="${1}"
  local MODULE_PROTOCOL="${2}"
  local MODULE_URL=""

  case "${MODULE_PROTOCOL}" in
    "ssh") MODULE_URL="git@github.com:${MODULE_LINE}.git" ;;
    "https") MODULE_URL="https://github.com/${MODULE_LINE}.git" ;;
  esac

  git -C "${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}" remote set-url origin \
    "${MODULE_URL}"
}

#  Check for changes in a module
function _satan-module-modified() {
  local MODULE_LINE="${1}"
  git -C "${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}" status --porcelain 2> \
    /dev/null
}

#  Write to the available modules index file
function _satan-index-available-write() {
  local REPOSITORY="${1}"
  grep "\"full_name\"" | sed "s/.*\"full_name\"\:\ \"\(.*\)\",/\1/" | \
    sort >> "${SATAN_INDEX_AVAILABLE}"
}

#  Add a module to the installed index file
function _satan-index-installed-write() {
  local MODULE_LINE="${1}"
  echo "${MODULE_LINE}" >> "${SATAN_INDEX_INSTALLED}"
}

#  Remove a module from the installed index file
function _satan-index-installed-remove() {
  local MODULE_LINE="${1}"
  local SATAN_INDEX_INSTALLED_TEMP=$(mktemp)
  cat "${SATAN_INDEX_INSTALLED}" | sed "/${MODULE_LINE//\//\\/}/d" > \
    "${SATAN_INDEX_INSTALLED_TEMP}"
  mv "${SATAN_INDEX_INSTALLED_TEMP}" "${SATAN_INDEX_INSTALLED}"
}

#  Index satan modules
function satan-repository-index() {
  echo -n "$(tput bold; tput setaf ${COLOR[green]})"
  echo "--> Indexing repositories..."

  satan-reload-configuration-variables

  rm -f "${SATAN_INDEX_AVAILABLE}"

  for repository in ${SATAN_REPOSITORIES[@]}; do
    echo "$(tput bold; tput setaf ${COLOR[magenta]})==> ${repository}"
    local REPOSITORY_URL="${GITHUB_API_URL}/orgs/${repository}/repos"
    curl --silent --request "GET" "${REPOSITORY_URL}" | \
      _satan-index-available-write
  done
}

#  Find an available module
function satan-module-available-find() {
  local MODULE="${1}"
  if [ -z "${MODULE}" ]; then
    return
  fi
  if [ -f "${SATAN_INDEX_AVAILABLE}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SATAN_INDEX_AVAILABLE}" | grep --max-count "1" --regexp "/${1}$"
    else
      cat "${SATAN_INDEX_AVAILABLE}" | grep --max-count "1" --regexp "${1}$"
    fi
  fi
}

#  Search available modules
function satan-module-available-search() {
  local MODULE="${1}"
  if [ -f "${SATAN_INDEX_AVAILABLE}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SATAN_INDEX_AVAILABLE}" | grep --regexp "/.*${1}.*"
    else
      cat "${SATAN_INDEX_AVAILABLE}" | grep --regexp ".*${1}.*"
    fi
  fi

}

#  Find an installed module
function satan-module-installed-find() {
  local MODULE="${1}"
  if [ -z "${MODULE}" ]; then
    return
  fi
  if [ -f "${SATAN_INDEX_INSTALLED}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SATAN_INDEX_INSTALLED}" | grep --max-count "1" --regexp "/${1}$"
    else
      cat "${SATAN_INDEX_INSTALLED}" | grep --max-count "1" --regexp "${1}$"
    fi
  fi
}

#  Search installed modules
function satan-module-installed-search() {
  local MODULE="${1}"
  if [ -f "${SATAN_INDEX_INSTALLED}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SATAN_INDEX_INSTALLED}" | grep  --regexp "/.*${1}.*"
    else
      cat "${SATAN_INDEX_INSTALLED}" | grep  --regexp ".*${1}.*"
    fi
  fi
}

#  Install a module
function satan-module-install() {
  local MODULE="${1}"
  local MODULE_LINE=$(satan-module-available-find "${MODULE}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPOSITORY="${MODULE_INFO[1]}"

  satan-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[magenta]})==> "
    echo "${MODULE}"
    echo -n "$(tput bold; tput setaf ${COLOR[white]})"
    echo "--> not found."
    return 0
  fi

  if [ -z "$(satan-module-installed-find ${MODULE_LINE})" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[magenta]})==> "
    echo "${MODULE_LINE}"

    echo -n "$(tput ${COLOR[reset]})"
    git clone "${GITHUB_URL}/${MODULE_REPOSITORY}/${MODULE_NAME}.git" \
      "${SATAN_MODULES_DIRECTORY}/${MODULE_REPOSITORY}/${MODULE_NAME}"

    if [ ${?} -eq 0 ]; then
      _satan-index-installed-write "${MODULE_LINE}"
    else
      echo -n "$(tput bold; tput setaf ${COLOR[red]})"
      echo "--> failure."
      return 1
    fi
  fi

}

#  Uninstall a module
function satan-module-uninstall() {
  local MODULE="${1}"
  local MODULE_LINE=$(satan-module-installed-find "${MODULE}")

  satan-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    return 0
  fi

  echo -n "$(tput bold; tput setaf ${COLOR[magenta]})==> "
  echo "${MODULE_LINE}"

  echo -n "$(tput ${COLOR[reset]})"
  rm -rf "${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}"

  if [ ${?} -eq 0 ]; then
    _satan-index-installed-remove "${MODULE_LINE}"
  else
    echo -n "$(tput bold; tput setaf ${COLOR[red]})"
    echo "--> failure."
    return 1
  fi
}

#  Update a module
function satan-module-update() {
  local MODULE="${1}"
  local MODULE_LINE=$(satan-module-installed-find "${MODULE}")
  local MODULE_DIRECTORY="${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}"

  satan-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[magenta]})==> "
    echo "${MODULE}"
    echo -n "$(tput bold; tput setaf ${COLOR[white]})"
    echo "--> not installed."
    return 0
  fi

  echo -n "$(tput bold; tput setaf ${COLOR[magenta]})==> "
  echo "${MODULE_LINE}"

  echo -n "$(tput ${COLOR[reset]})"
  git -C "${MODULE_DIRECTORY}" pull

  if [ ! ${?} -eq 0 ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[red]})"
    echo "--> failure."
    return 1
  fi
}

#  Load a module
function satan-module-load() {
  local MODULE="${1}"
  local MODULE_LINE=$(satan-module-installed-find "${MODULE}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPOSITORY="${MODULE_INFO[1]}"

  local MODULE_DIRECTORY="${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_FILES=(${MODULE_DIRECTORY}/*.sh)

  satan-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[red]})==> "
    echo "${MODULE}"
    echo -n "$(tput bold; tput setaf ${COLOR[white]})"
    echo "--> not installed."
    return 1
  fi

  if [ "${SATAN_DISPLAY_MODULE_LOAD}" = "true" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[magenta]})==> "
    echo "${MODULE_LINE}"
    echo -n "$(tput ${COLOR[reset]})"
  fi

  for file in ${MODULE_FILES[@]}; do
    MODULE_REPOSITORY="${MODULE_REPOSITORY}" MODULE_NAME="${MODULE_NAME}" \
      MODULE_DIRECTORY="${MODULE_DIRECTORY}" \
      source "${file}"
  done
}

#  Enable developer mode
function satan-module-developer-enable() {
  local MODULE="${1}"
  local MODULE_LINE=$(satan-module-installed-find "${MODULE}")

  satan-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[magenta]})==> "
    echo "${MODULE}"
    echo -n "$(tput bold; tput setaf ${COLOR[white]})"
    echo "--> not installed."
    return 0
  fi

  local MODULE_SSH=$(_satan-module-get-url "${MODULE_LINE}" | grep "git@")

  if [ -z "${MODULE_SSH}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[magenta]})==> "
    echo "${MODULE_LINE}"

    _satan-module-set-url "${MODULE_LINE}" "ssh"

    if [ ! ${?} -eq 0 ]; then
      echo -n "$(tput bold; tput setaf ${COLOR[red]})"
      echo "--> failure."
      return 1
    fi
  fi
}

#  Disable developer mode
function satan-module-developer-disable() {
  local MODULE="${1}"
  local MODULE_LINE=$(satan-module-installed-find "${MODULE}")

  satan-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[magenta]})==> "
    echo "${MODULE}"
    echo -n "$(tput bold; tput setaf ${COLOR[white]})"
    echo "--> not installed."
    return 0
  fi

  local MODULE_HTTPS=$(_satan-module-get-url "${MODULE_LINE}" | grep "https")

  if [ -z "${MODULE_HTTPS}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[magenta]})==> "
    echo "${MODULE_LINE}"

    _satan-module-set-url "${MODULE_LINE}" "https"

    if [ ! ${?} -eq 0 ]; then
      echo -n "$(tput bold; tput setaf ${COLOR[red]})"
      echo "--> failure."
      return 1
    fi
  fi
}

#  Check for changes in modules
function satan-module-developer-status() {
  local MODULE="${1}"
  local MODULE_LINE=$(satan-module-installed-find "${MODULE}")

  satan-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[magenta]})==> "
    echo "${MODULE}"
    echo -n "$(tput bold; tput setaf ${COLOR[white]})"
    echo "--> not installed."
    return 0
  fi

  if [ -n "$(_satan-module-modified ${MODULE_LINE})" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[magenta]})==> "
    echo "${MODULE_LINE}"
    echo -n "$(tput setaf ${COLOR[white]})"
    echo "--> modified."
  fi
}

#  Find a list of available modules
function satan-modules-available-find() {
  echo -n "$(tput bold; tput setaf ${COLOR[green]})"
  echo "--> Finding available modules..."
  echo -n "$(tput ${COLOR[reset]})"
  for module in ${@}; do
    satan-module-available-find "${module}"
  done
}

#  Search a list of available modules
function satan-modules-available-search() {
  echo -n "$(tput bold; tput setaf ${COLOR[green]})"
  echo "--> Searching available modules..."
  echo -n "$(tput ${COLOR[reset]})"
  for module in ${@}; do
    satan-module-available-search "${module}"
  done
}

#  Find a list of installed modules
function satan-modules-installed-find() {
  echo -n "$(tput bold; tput setaf ${COLOR[green]})"
  echo "--> Finding installed modules..."
  echo -n "$(tput ${COLOR[reset]})"
  for module in ${@}; do
    satan-module-installed-find "${module}"
  done
}

#  Search a list of installed modules
function satan-modules-installed-search() {
  echo -n "$(tput bold; tput setaf ${COLOR[green]})"
  echo "--> Searching installed modules..."
  echo -n "$(tput ${COLOR[reset]})"
  for module in ${@}; do
    satan-module-installed-search "${module}"
  done
}

#  Install a list of modules
function satan-modules-install() {
  echo -n "$(tput bold; tput setaf ${COLOR[green]})"
  echo "--> Installing modules..."
  for module in ${@}; do
    satan-module-install "${module}"
  done
}

#  Uninstall a list of modules
function satan-modules-uninstall() {
  echo -n "$(tput bold; tput setaf ${COLOR[green]})"
  echo "--> Uninstalling modules..."
  for module in ${@}; do
    satan-module-uninstall "${module}"
  done
}

#  Update a list of modules
function satan-modules-update() {
  echo -n "$(tput bold; tput setaf ${COLOR[green]})"
  echo "--> Updating modules..."
  for module in ${@}; do
    satan-module-update "${module}"
  done
}

#  Load a list of modules
function satan-modules-load() {
  satan-reload-configuration-variables

  if [ "${SATAN_DISPLAY_MODULE_LOAD}" = "true" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[green]})"
    echo "--> Loading modules..."
  fi

  for module in ${@}; do
    satan-module-load "${module}"
  done
}

#  Enable developer mode for a list of modules
function satan-modules-developer-enable() {
  echo -n "$(tput bold; tput setaf ${COLOR[green]})"
  echo "--> Enabling developer mode..."
  for module in ${@}; do
    satan-module-developer-enable "${module}"
  done
}

#  Disable developer mode for a list of modules
function satan-modules-developer-disable() {
  echo -n "$(tput bold; tput setaf ${COLOR[green]})"
  echo "--> Disabling developer mode..."
  for module in ${@}; do
    satan-module-developer-disable "${module}"
  done
}

#  Check for changes in a list of modules
function satan-modules-developer-status() {
  echo -n "$(tput bold; tput setaf ${COLOR[green]})"
  echo "--> Checking modules for changes..."
  for module in ${@}; do
    satan-module-developer-status "${module}"
  done
}

#  Install active modules
function satan-modules-active-install() {
  satan-modules-install ${SATAN_MODULES[@]}
}

#  Update active modules
function satan-modules-active-update() {
  satan-modules-update ${SATAN_MODULES[@]}
}

#  Load active modules
function satan-modules-active-load() {
  satan-modules-load ${SATAN_MODULES[@]}
}

#  Enable developer mode for active modules
function satan-developer-enable() {
  satan-modules-developer-enable ${SATAN_MODULES[@]}
}

#  Disable developer mode for active modules
function satan-developer-disable() {
  satan-modules-developer-disable ${SATAN_MODULES[@]}
}

#  Check for changes in active modules
function satan-developer-status() {
  satan-modules-developer-status ${SATAN_MODULES[@]}
}

#  Source satan-shell environment files
function satan-reload() {
  echo -n "$(tput bold; tput setaf ${COLOR[green]})"
  echo "--> Reloading satan-shell..."
  echo -n "$(tput ${COLOR[reset]})"
  for file in ${SATAN_FILES[@]}; do
    source "${HOME}/.${file}"
  done
}

#  Update satan-shell and active modules
function satan-update() {
  echo -n "$(tput bold; tput setaf ${COLOR[green]})"
  echo "--> Updating satan-shell..."
  echo -n "$(tput ${COLOR[reset]})"

  satan-reload-configuration-variables

  git -C "${SATAN_INSTALL_DIRECTORY}" pull

  satan-modules-active-update
  satan-reload
}

#  Display readme for satan-shell or a module
function satan-info() {
  local MODULE="${1}"
  local MODULE_LINE=$(satan-module-installed-find "${MODULE}")
  local README=""

  satan-reload-configuration-variables

  if [ -n "${MODULE}" ]; then
    if [ -n "${MODULE_LINE}" ]; then
      README="${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}/README.md"
    else
      echo -n "$(tput bold; tput setaf ${COLOR[white]})"
      echo "--> module not found."
      return
    fi
  else
    README="${SATAN_INSTALL_DIRECTORY}/README.md"
  fi

  if [ ! -f "${README}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[white]})"
    echo "--> readme not found."
    return
  fi

  if [ -n "$(command -v mdv)" ]; then
    mdv -t "${SATAN_MARKDOWN_VIEWER_THEME}" "${README}" | less -R
  else
    cat "${README}" | less
    echo -n "$(tput bold; tput setaf ${COLOR[white]})"
    echo "--> install mdv (terminal markdown viewer) for formated output."
  fi
}

#  Satan module manager
function satan() {
  local INSTALL_MODULES=""
  local UNINSTALL_MODULES=""
  local AVALIABLE_SEARCH=""
  local INSTALLED_SEARCH=""
  local GENERATE_INDEX=""
  local LOAD_MODULES=""
  local ACTIVATED_MODULES=""

  local MODULE_LIST=()

  while getopts ":SRQXyla" option; do
    case $option in
      "S") INSTALL_MODULES="true" ;;
      "R") UNINSTALL_MODULES="true" ;;
      "Q") AVAILABLE_SEARCH="true" ;;
      "X") INSTALLED_SEARCH="true" ;;
      "y") GENERATE_INDEX="true" ;;
      "l") LOAD_MODULES="true" ;;
      "a") ACTIVATED_MODULES="true" ;;
      *) ;;
    esac
  done

  satan-reload-configuration-variables

  MODULE_LIST=(${@:${OPTIND}})

  if [ -n "${ACTIVATED_MODULES}" ]; then
    MODULE_LIST=(${SATAN_MODULES[@]})
  fi

  if [ -n "${GENERATE_INDEX}" ]; then
    satan-repository-index
  fi

  if [ -n "${INSTALL_MODULES}" ]; then
    satan-modules-install ${MODULE_LIST[@]}

    if [ ! ${?} -eq 0 ]; then
      return ${?}
    fi
  fi

  if [ -n "${LOAD_MODULES}" ]; then
    satan-modules-load ${MODULE_LIST[@]}
    return ${?}
  fi

  if [ -n "${UNINSTALL_MODULES}" ]; then
    satan-modules-uninstall ${MODULE_LIST[@]}
    return ${?}
  fi

  if [ -n "${AVAILABLE_SEARCH}" ]; then
    if [ -z "${MODULE_LIST[@]}" ]; then
      echo -n "$(tput bold; tput setaf ${COLOR[green]})"
      echo "--> Available modules..."
      echo -n "$(tput ${COLOR[reset]})"
      satan-module-available-search
      return ${?}
    fi
    satan-modules-available-search ${MODULE_LIST[@]}
    return ${?}
  fi

  if [ -n "${INSTALLED_SEARCH}" ]; then
    if [ -z "${MODULE_LIST[@]}" ]; then
      echo -n "$(tput bold; tput setaf ${COLOR[green]})"
      echo "--> Installed modules..."
      echo -n "$(tput ${COLOR[reset]})"
      satan-module-installed-search
      return ${?}
    fi
    satan-modules-installed-search ${MODULE_LIST[@]}
    return ${?}
  fi
}
