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

#  Write to the modules index file
function _satan-write-index() {
  grep "\"name\"" | \
    sed "s/.*\"name\"\:\ \"\([a-zA-Z0-9]*\)\",/${1}\/\1/" \
    >> "${SATAN_AVAILABLE}"
}

#  Index satan modules
function satan-repository-index() {
  rm -f "${SATAN_AVAILABLE}"
  for repository in ${SATAN_REPOSITORIES[@]}; do
    local REPOSITORY_URL="${GITHUB_API_URL}/orgs/${repository}/repos"
    curl --silent --request "GET" "${REPOSITORY_URL}" | \
      _satan-write-index "${repository}"
  done
}

#  Find an available module
function satan-repository-find() {
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
function satan-repository-search() {
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
  local MODULE_LINE=$(satan-repository-find "${MODULE}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPO="${MODULE_INFO[1]}"

  echo -n "$(tput bold; tput setaf 2)==> "

  if [ -z "${MODULE_LINE}" ]; then
    echo "${MODULE}"
    echo -n "$(tput setaf 4)"
    echo "--> not found."
    return 1
  fi

  if [ -n "$(satan-installed-find ${MODULE_LINE})" ]; then
    echo "${MODULE_LINE}"
    echo -n "$(tput setaf 4)"
    echo "--> already installed."
    return 1
  fi

  echo "${MODULE_LINE}"
  echo -n "$(tput setaf 6)"
  echo "--> installing..."

  echo -n "$(tput sgr0)"

  git clone "${GITHUB_URL}/${MODULE_REPO}/${MODULE_NAME}.git" \
    "${SATAN_MODULES_DIRECTORY}/${MODULE_REPO}/${MODULE_NAME}"

  if [ ${?} -eq 0 ]; then
    echo "${MODULE_LINE}" >> "${SATAN_INSTALLED}"
    echo -n "$(tput bold; tput setaf 6)"
    echo "--> success."
    echo -n "$(tput sgr0)"
  else
    echo -n "$(tput bold; tput setaf 1)"
    echo "--> failure."
    echo -n "$(tput sgr0)"
    return 1
  fi
}

#  Uninstall a module
function satan-module-uninstall() {
  local MODULE="${1}"
  local MODULE_LINE=$(satan-installed-find "${MODULE}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPO="${MODULE_INFO[1]}"

  echo -n "$(tput bold; tput setaf 2)==> "

  if [ -z "${MODULE_LINE}" ]; then
    echo "${MODULE}"
    echo -n "$(tput setaf 4)"
    echo "--> not installed."
    return 1
  fi

  echo "${MODULE_LINE}"
  echo -n "$(tput setaf 6)"
  echo "--> uinstalling..."

  echo -n "$(tput sgr0)"

  rm -rf "${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}"

  if [ ${?} -eq 0 ]; then
    if [ "$(uname)" = "Darwin" ]; then
      sed -i "" "/${MODULE_LINE//\//\\/}/d" "${SATAN_INSTALLED}"
    else
      sed -i "/${MODULE_LINE//\//\\/}/d" "${SATAN_INSTALLED}"
    fi
    echo -n "$(tput bold; tput setaf 6)"
    echo "--> success."
    echo -n "$(tput sgr0)"
  else
    echo -n "$(tput bold; tput setaf 1)"
    echo "--> failure."
    echo -n "$(tput sgr0)"
  fi
}

#  Update a module
function satan-module-update() {
  local MODULE="${1}"
  local MODULE_LINE=$(satan-installed-find "${MODULE}")
  local MODULE_DIRECTORY="${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}"

  if [ -z "${MODULE_LINE}" ]; then
    echo "${MODULE} not installed."
    return 1
  fi

  git -C "${MODULE_DIRECTORY}" pull

  if [ ! ${?} -eq 0 ]; then
    echo "${MODULE_LINE} git pull failed."
  fi
}

#  Load a module
function satan-module-load() {
  local MODULE="${1}"
  local MODULE_LINE=$(satan-installed-find "${MODULE}")
  local MODULE_DIRECTORY="${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_FILES=(${MODULE_DIRECTORY}/*.sh)

  if [ -z "${MODULE_LINE}" ]; then
    echo "${MODULE} not installed."
    return 1
  fi

  for file in ${MODULE_FILES[@]}; do
    MODULE_DIRECTORY="${MODULE_DIRECTORY}" source "${file}"
  done
}

#  Enable developer mode
function satan-module-developer-enable() {
  local MODULE="${1}"
  local MODULE_LINE=$(satan-installed-find "${MODULE}")

  if [ -z "${MODULE_LINE}" ]; then
    echo "${MODULE} not installed."
  fi

  git -C "${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}" \
    remote set-url origin "git@github.com:${MODULE_LINE}.git"

  if [ ! ${?} -eq 0 ]; then
    echo "${MODULE_LINE} git remote set-url origin failed."
  fi
}

#  Disable developer mode
function satan-module-developer-disable() {
  local MODULE="${1}"
  local MODULE_LINE=$(satan-installed-find "${MODULE}")

  if [ -z "${MODULE_LINE}" ]; then
    echo "${MODULE} not installed."
  fi

  git -C "${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}" \
    remote set-url origin "https://github.com/${MODULE_LINE}.git"

  if [ ! ${?} -eq 0 ]; then
    echo "${MODULE_LINE} git remote set-url origin failed."
  fi
}

#  Install a list of modules
function satan-modules-install() {
  for module in ${@}; do
    satan-module-install "${module}"
  done
}

#  Uninstall a list of modules
function satan-modules-uninstall() {
  for module in ${@}; do
    satan-module-uninstall "${module}"
  done
}

#  Update a list of modules
function satan-modules-update() {
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
  for module in ${@}; do
    satan-module-developer-enable "${module}"
  done
}

#  Disable developer mode for a list of modules
function satan-modules-developer-disable() {
  for module in ${@}; do
    satan-module-developer-disable "${module}"
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
function satan-modules-active-developer-enable() {
  satan-modules-developer-enable ${MODULES[@]}
}

#  Disable developer mode for active modules
function satan-modules-active-developer-disable() {
  satan-modules-developer-disable ${MODULES[@]}
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
    satan-repository-search "${SEARCH}"
  fi
}
