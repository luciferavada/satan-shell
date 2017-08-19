#  Do not modify this file
#  Source required files
source "${HOME}/.zsh.d/rc.conf"
source "${HOME}/.zsh.d/modules.conf"

#  Github API URL
local GITHUB_API_URL="https://api.github.com"

#  Environment files
local SATAN_FILES=("zshenv" "zprofile" "zshrc" "zlogin")

#  Satan repositories
local SATAN_REPOSITORIES=("satan-core" "satan-extra" "satan-community")

#  Satan modules index
local SATAN_INDEX="${SATAN_INSTALL_DIRECTORY}/.zsh.d/.modules.index"

#  Satan modules installed
local SATAN_INSTALLED="${SATAN_INSTALL_DIRECTORY}/.zsh.d/.modules.installed"

#  Write to the modules index file
function _satan-write-index() {
  grep "\"name\"" | \
    sed "s/.*\"name\"\:\ \"\([a-zA-Z0-9]*\)\",/${1}\/\1/" | \
    >> "${SATAN_INDEX}"
}

#  Index satan modules
function _satan-index() {
  for repository in ${SATAN_REPOSITORIES[@]}; do
    local REPOSITORY_URL="${GITHUB_API_URL}/orgs/${repository}/repos"
    curl --silent --request "GET" "${REPOSITORY_URL}" | \
      _satan-write-index "${repository}"
  done
}

#  Index user modules
function _satan-index-user() {
  for repository in ${SATAN_USER_REPOSITORIES[@]}; do
    local REPOSITORY_URL="${GITHUB_API_URL}/users/${repository}/repos"
    curl --silent --request "GET" "${REPOSITORY_URL}" | \
      _satan-write-index "${repository}"
  done
}

#  Index organization modules
function _satan-index-organization() {
  for repository in ${SATAN_ORGANIZATION_REPOSITORIES[@]}; do
    local REPOSITORY_URL="${GITHUB_API_URL}/orgs/${repository}/repos"
    curl --silent --request "GET" "${REPOSITORY_URL}" | \
      _satan-write-index "${repository}"
  done
}

#  Index core, user and organization modules
function satan-index-all() {
  rm -f "${SATAN_INDEX}"
  _satan-index
  _satan-index-user
  _satan-index-organization
}

#  Find an available module
function satan-repository-find() {
  if [ -f "${SATAN_INDEX}" ]; then
    local SPLIT=(`echo ${1//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SATAN_INDEX}" | grep --max-count "1" --regexp "/${1}$"
    else
      cat "${SATAN_INDEX}" | grep --max-count "1" --regexp "${1}$"
    fi
  fi
}

#  Find an installed module
function satan-installed-find() {
  if [ ! -f "${SATAN_INSTALLED}" ]; then
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
  if [ -f "${SATAN_INDEX}" ]; then
    local SPLIT=(`echo ${1//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SATAN_INDEX}" | grep --regexp "/.*${1}.*"
    else
      cat "${SATAN_INDEX}" | grep --regexp ".*${1}.*"
    fi
  fi

}

#  Search installed modules
function satan-installed-search() {
  if [ ! -f "${SATAN_INSTALLED}" ]; then
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

  if [ -n $(satan-installed-find "${MODULE_NAME}") ]; then
    echo "${MODULE_NAME} already installed."
    return 1
  fi

  if [ -z "${MODULE_LINE}" ]; then
    echo "${MODULE_NAME} not found."
    return 1
  fi

  git clone "https://github.com/${MODULE_REPO}/${MODULE_NAME}.git" \
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

  rm -rf "${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}"
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
    satan-index-all
  fi

  if [ -n "${INSTALL}" ]; then
    return satan-install "${INSTALL}"
  fi

  if [ -n "${SEARCH}" ]; then
    satan-repository-search "${SEARCH}"
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

      done

    done
  done

  echo "${MODULES_ACTIVE[@]}"
}

#  Load activated modules
function satan-modules-active-load() {
  local MODULES_ACTIVE=(`satan-modules-active`)
  for module in ${MODULES_ACTIVE[@]}; then
    local MODULE_FILES=(${module}/*.sh)
    for file in ${MODULE_FILES[@]}; do
      source "${file}"
    done
  fi
}

#  Update activated modules
function satan-modules-active-update() {
  local MODULES_ACTIVE=(`satan-modules-active`)
  for module in ${MODULES_ACTIVE[@]}; then
    git -C "${module_directory}" pull
  fi
}

#  Source satan-shell environment files
function satan-load satan-reload() {
  for file in ${SATAN_FILES[@]}; do
    if [ -f "${file}" ]; then
      source "${HOME}/.${file}"
    fi
  done
}

#  Update satan-shell and active modules
function satan-update() {
  git -C "${SATAN_INSTALL_DIRECTORY}" pull
  satan-modules-active-update
  satan-reload
}
