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
function satan-install() {
  local MODULE_LINE=$(satan-repository-find "${1}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPO="${MODULE_INFO[1]}"

  if [ -n "$(satan-installed-find ${MODULE_LINE})" ]; then
    echo "${MODULE_LINE} already installed."
    return 1
  fi

  if [ -z "${MODULE_LINE}" ]; then
    echo "${MODULE_NAME} not found."
    return 1
  fi

  git clone "${GITHUB_URL}/${MODULE_REPO}/${MODULE_NAME}.git" \
    "${SATAN_MODULES_DIRECTORY}/${MODULE_REPO}/${MODULE_NAME}"

  if [ ${?} ]; then
    echo "${MODULE_LINE}" >> "${SATAN_INSTALLED}"
  else
    echo "${MODULE_NAME} git clone failed."
    return 1
  fi
}

#  Uninstall a module
function satan-uninstall() {
  local MODULE_LINE=$(satan-installed-find "${1}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPO="${MODULE_INFO[1]}"

  if [ -z "${MODULE_LINE}" ]; then
    echo "${MODULE_NAME} not installed."
    return 1
  fi

  rm -rfv "${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}" | grep -v ".git"

  if [ ${?} ]; then
    if [ "$(uname)" = "Darwin" ]; then
      sed -i "" "/${MODULE_LINE//\//\\/}/d" "${SATAN_INSTALLED}"
    else
      sed -i "/${MODULE_LINE//\//\\/}/d" "${SATAN_INSTALLED}"
    fi
  else
    echo "${MODULE_LINE} not properly removed."
  fi
}

#  Echo a list of active module directories
function satan-modules-active() {
  local REPOSITORIES=(${SATAN_MODULES_DIRECTORY}/*)
  local MODULES_ACTIVE=()

  for module in ${MODULES[@]}; do
    for repository in ${REPOSITORIES[@]}; do

      local MODULE_DIRECTORIES=(${repository}/*)
      for module_directory in ${MODULE_DIRECTORIES[@]}; do

        local MODULE_NAME=$(basename ${module_directory})
        if [ "${module}" = "${MODULE_NAME}" ]; then
          MODULES_ACTIVE+=("${module_directory}")
        fi

      done

    done
  done

  echo "${MODULES_ACTIVE[@]}"
}

#  Install active modules
function satan-modules-active-install() {
  for module in ${MODULES[@]}; do
    satan-install "${module}"
  done
}

#  Load active modules
function satan-modules-active-load() {
  local MODULES_ACTIVE=(`satan-modules-active`)
  for module_directory in ${MODULES_ACTIVE[@]}; do
    local MODULE_FILES=(${module_directory}/*.sh)
    for file in ${MODULE_FILES[@]}; do
      MODULE_DIRECTORY="${module_directory}" source "${file}"
    done
  done
}

#  Update active modules
function satan-modules-active-update() {
  local MODULES_ACTIVE=(`satan-modules-active`)
  for module in ${MODULES_ACTIVE[@]}; do
    git -C "${module_directory}" pull
  done
}

#  Source satan-shell environment files
function satan-load satan-reload() {
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
    return satan-install "${INSTALL}"
  fi

  if [ -n "${SEARCH}" ]; then
    satan-repository-search "${SEARCH}"
  fi
}
