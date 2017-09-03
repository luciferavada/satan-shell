#  Do not modify this file
#  Source required files
source "${HOME}/.zsh.d/rc.conf"
source "${HOME}/.zsh.d/modules.conf"

#  Github URL
local GITHUB_URL="https://github.com"

#  Github API URL
local GITHUB_API_URL="https://api.github.com"

#  Environment files
local SATAN_FILES=("zshenv" "zprofile" "zshrc" "zlogin")

#  Satan modules index
local SATAN_AVAILABLE="${SATAN_INSTALL_DIRECTORY}/zsh.d/.modules.available"

#  Satan modules installed
local SATAN_INSTALLED="${SATAN_INSTALL_DIRECTORY}/zsh.d/.modules.installed"

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
  grep "\"full_name\"" | sed "s/.*\"full_name\"\:\ \"\(.*\)\",/\1/" >> \
    "${SATAN_AVAILABLE}"
}

#  Remove a module from the installed index file
function _satan-index-installed-remove() {
  local MODULE_LINE="${1}"
  local SATAN_INSTALLED_TEMP=$(mktemp)
  cat "${SATAN_INSTALLED}" | sed "/${MODULE_LINE//\//\\/}/d" > \
    "${SATAN_INSTALLED_TEMP}"
  mv "${SATAN_INSTALLED_TEMP}" "${SATAN_INSTALLED}"
}

#  Index satan modules
function satan-repository-index() {
  rm -f "${SATAN_AVAILABLE}"
  for repository in ${SATAN_REPOSITORIES[@]}; do
    local REPOSITORY_URL="${GITHUB_API_URL}/orgs/${repository}/repos"
    curl --silent --request "GET" "${REPOSITORY_URL}" | \
      _satan-index-available-write
  done
}

#  Find an available module
function satan-available-find() {
  if [ -f "${SATAN_AVAILABLE}" ]; then
    local SPLIT=(`echo ${1//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SATAN_AVAILABLE}" | grep --max-count "1" --regexp "/${1}$"
    else
      cat "${SATAN_AVAILABLE}" | grep --max-count "1" --regexp "${1}$"
    fi
  fi
}

#  Search available modules
function satan-available-search() {
  if [ -f "${SATAN_AVAILABLE}" ]; then
    local SPLIT=(`echo ${1//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SATAN_AVAILABLE}" | grep --regexp "/.*${1}.*"
    else
      cat "${SATAN_AVAILABLE}" | grep --regexp ".*${1}.*"
    fi
  fi

}

#  Find an installed module
function satan-installed-find() {
  if [ -f "${SATAN_INSTALLED}" ]; then
    local SPLIT=(`echo ${1//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SATAN_INSTALLED}" | grep --max-count "1" --regexp "/${1}$"
    else
      cat "${SATAN_INSTALLED}" | grep --max-count "1" --regexp "${1}$"
    fi
  fi
}

#  Search installed modules
function satan-installed-search() {
  if [ -f "${SATAN_INSTALLED}" ]; then
    local SPLIT=(`echo ${1//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SATAN_INSTALLED}" | grep  --regexp "/.*${1}.*"
    else
      cat "${SATAN_INSTALLED}" | grep  --regexp ".*${1}.*"
    fi
  fi
}

#  Install a module
function satan-module-install() {
  local MODULE="${1}"
  local MODULE_LINE=$(satan-available-find "${MODULE}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPO="${MODULE_INFO[1]}"

  if [ -z "${MODULE_LINE}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[green]})==> "
    echo "${MODULE}"
    echo -n "$(tput setaf ${COLOR[magenta]})"
    echo "--> not found."
    return 0
  fi

  if [ -z "$(satan-installed-find ${MODULE_LINE})" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[green]})==> "
    echo "${MODULE_LINE}"

    echo -n "$(tput setaf ${COLOR[cyan]})"
    git clone "${GITHUB_URL}/${MODULE_REPO}/${MODULE_NAME}.git" \
      "${SATAN_MODULES_DIRECTORY}/${MODULE_REPO}/${MODULE_NAME}"

    if [ ${?} -eq 0 ]; then
      echo "${MODULE_LINE}" >> "${SATAN_INSTALLED}"
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
  local MODULE_LINE=$(satan-installed-find "${MODULE}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPO="${MODULE_INFO[1]}"

  if [ -z "${MODULE_LINE}" ]; then
    return 0
  fi

  echo -n "$(tput bold; tput setaf ${COLOR[green]})==> "
  echo "${MODULE_LINE}"
  echo -n "$(tput setaf ${COLOR[cyan]})"
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
  local MODULE_LINE=$(satan-installed-find "${MODULE}")
  local MODULE_DIRECTORY="${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}"

  if [ -z "${MODULE_LINE}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[green]})==> "
    echo "${MODULE}"
    echo -n "$(tput setaf ${COLOR[magenta]})"
    echo "--> not installed."
    return 0
  fi

  echo -n "$(tput bold; tput setaf ${COLOR[green]})==> "
  echo "${MODULE_LINE}"

  echo -n "$(tput setaf ${COLOR[cyan]})"
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
  local MODULE_LINE=$(satan-installed-find "${MODULE}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPO="${MODULE_INFO[1]}"

  local MODULE_DIRECTORY="${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_FILES=(${MODULE_DIRECTORY}/*.sh)

  if [ -z "${MODULE_LINE}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[red]})==> "
    echo "${MODULE} not installed."
    return 1
  fi

  for file in ${MODULE_FILES[@]}; do
    MODULE_REPO="${MODULE_REPO}" MODULE_NAME="${MODULE_NAME}" \
      MODULE_DIRECTORY="${MODULE_DIRECTORY}" \
      source "${file}"
  done
}

#  Enable developer mode
function satan-module-developer-enable() {
  local MODULE="${1}"
  local MODULE_LINE=$(satan-installed-find "${MODULE}")

  if [ -z "${MODULE_LINE}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[green]})==> "
    echo "${MODULE}"
    echo -n "$(tput setaf ${COLOR[magenta]})"
    echo "--> not installed."
    return 0
  fi

  local MODULE_SSH=$(_satan-module-get-url "${MODULE_LINE}" | grep "git@")

  if [ -z "${MODULE_SSH}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[green]})==> "
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
  local MODULE_LINE=$(satan-installed-find "${MODULE}")

  if [ -z "${MODULE_LINE}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[green]})==> "
    echo "${MODULE}"
    echo -n "$(tput setaf ${COLOR[magenta]})"
    echo "--> not installed."
    return 0
  fi

  local MODULE_HTTPS=$(_satan-module-get-url "${MODULE_LINE}" | grep "https")

  if [ -z "${MODULE_HTTPS}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[green]})==> "
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
  local MODULE_LINE=$(satan-installed-find "${MODULE}")

  if [ -z "${MODULE_LINE}" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[green]})==> "
    echo "${MODULE}"
    echo -n "$(tput setaf ${COLOR[magenta]})"
    echo "--> not installed."
    return 0
  fi

  if [ -n "$(_satan-module-modified ${MODULE_LINE})" ]; then
    echo -n "$(tput bold; tput setaf ${COLOR[green]})==> "
    echo "${MODULE_LINE}"
    echo -n "$(tput setaf ${COLOR[magenta]})"
    echo "--> modified."
  fi
}

#  Install a list of modules
function satan-modules-install() {
  echo -n "$(tput bold; tput setaf ${COLOR[white]})"
  echo "--> Installing modules..."
  for module in ${@}; do
    satan-module-install "${module}"
  done
}

#  Uninstall a list of modules
function satan-modules-uninstall() {
  echo -n "$(tput bold; tput setaf ${COLOR[white]})"
  echo "--> Uninstalling modules..."
  for module in ${@}; do
    satan-module-uninstall "${module}"
  done
}

#  Update a list of modules
function satan-modules-update() {
  echo -n "$(tput bold; tput setaf ${COLOR[white]})"
  echo "--> Updating modules..."
  for module in ${@}; do
    satan-module-update "${module}"
  done
}

#  Load a list of modules
function satan-modules-load() {
  for module in ${@}; do
    satan-module-load "${module}"
  done
}

#  Enable developer mode for a list of modules
function satan-modules-developer-enable() {
  echo -n "$(tput bold; tput setaf ${COLOR[white]})"
  echo "--> Enabling developer mode..."
  for module in ${@}; do
    satan-module-developer-enable "${module}"
  done
}

#  Disable developer mode for a list of modules
function satan-modules-developer-disable() {
  echo -n "$(tput bold; tput setaf ${COLOR[white]})"
  echo "--> Disabling developer mode..."
  for module in ${@}; do
    satan-module-developer-disable "${module}"
  done
}

#  Check for changes in a list of modules
function satan-modules-developer-status() {
  echo -n "$(tput bold; tput setaf ${COLOR[white]})"
  echo "--> Checking modules for changes..."
  for module in ${@}; do
    satan-module-developer-status "${module}"
  done
}

#  Install active modules
function satan-modules-active-install() {
  satan-modules-install ${MODULES[@]}
}

#  Update active modules
function satan-modules-active-update() {
  satan-modules-update ${MODULES[@]}
}

#  Load active modules
function satan-modules-active-load() {
  satan-modules-load ${MODULES[@]}
}

#  Enable developer mode for active modules
function satan-developer-enable() {
  satan-modules-developer-enable ${MODULES[@]}
}

#  Disable developer mode for active modules
function satan-developer-disable() {
  satan-modules-developer-disable ${MODULES[@]}
}

#  Check for changes in active modules
function satan-developer-status() {
  satan-modules-developer-status ${MODULES[@]}
}

#  Source satan-shell environment files
function satan-init satan-reload() {
  for file in ${SATAN_FILES[@]}; do
    if [ -f "${file}" ]; then
      source "${SATAN_INSTALL_DIRECTORY}/${file}"
    fi
  done
}

#  Update satan-shell and active modules
function satan-update() {
  git -C "${SATAN_INSTALL_DIRECTORY}" pull
  satan-modules-active-update
  satan-reload
}

#  Satan module manager
function satan() {
  local INSTALL=""
  local SEARCH=""
  local INDEX="false"

  while getopts ":i:s:y" option; do
    case $option in
      "i") INSTALL="${OPTARG}" ;;
      "s") SEARCH="${OPTARG}" ;;
      "y") INDEX="true" ;;
      *) ;;
    esac
  done

  if [ "${INDEX}" = "true" ]; then
    satan-repository-index
  fi

  if [ -n "${INSTALL}" ]; then
    return satan-module-install "${INSTALL}"
  fi

  if [ -n "${SEARCH}" ]; then
    satan-available-search "${SEARCH}"
  fi
}
