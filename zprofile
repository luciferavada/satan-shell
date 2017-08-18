#  Source required files
source "${HOME}/.zsh.d/rc.conf"
source "${HOME}/.zsh.d/modules.conf"

#  Source utilities file
source "${SATAN_INSTALL_DIRECTORY}/util/util.sh"

#  Github API URL
local GITHUB_API_URL="https://api.github.com"

#  Environment files
local SATAN_FILES=("zshenv" "zprofile" "zshrc" "zlogin")

#  Satan repositories
local SATAN_REPOSITORIES=("satan-core" "satan-extra" "satan-community")

#  Satan modules index
local SATAN_INDEX="${SATAN_INSTALL_DIRECTORY}/zsh.d/.modules.index"

#  Satan modules installed
local SATAN_INSTALLED="${SATAN_INSTALL_DIRECTORY}/.zsh.d/.modules.installed"

#  Source environment files
function environment-load() {
  for file in ${SATAN_FILES[@]}; do
    if [ -f "${file}" ]; then
      source "${HOME}/.${file}"
    fi
  done
}

#  Index available modules
function satan-index() {
  rm -f "${SATAN_INDEX}"
  for repository in ${SATAN_REPOSITORIES[@]}; do
    local REPOSITORY_URL="${GITHUB_API_URL}/orgs/${repository}/repos"
    curl --silent --request "GET" "${REPOSITORY_URL}" | \
      grep "\"name\"" | \
      sed "s/.*\"name\"\:\ \"\([a-zA-Z0-9]*\)\",/${repository}\/\1/" >> \
      "${SATAN_INDEX}"
  done
}

#  Find for a module
function satan-repository-find() {
  if [ -f "${SATAN_INDEX}" ]; then
    cat "${SATAN_INDEX}" | grep -e "/${1}$"
  fi
}

#  Search for a module
function satan-repository-search() {
  if [ -f "${SATAN_INDEX}" ]; then
    cat "${SATAN_INDEX}" | grep -e "/.*${1}.*"
  fi

}

#  Find an installed module
function satan-installed-find() {
  if [ ! -f "${SATAN_INSTALLED}" ]; then
    cat "${SATAN_INSTALLED}" | grep -e "/${1}$"
  fi
}

#  Search for an installed module
function satan-installed-search() {
  if [ ! -f "${SATAN_INSTALLED}" ]; then
    cat "${SATAN_INSTALLED}" | grep -e "/.*${1}.*"
  fi
}

#  Install a module
function satan-install() {
  local MODULE_LINE=$(satan-repository-find "${1}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPO="${MODULE_INFO[1]}"

  if [ -n $(satan-installed-find "${MODULES_NAME}") ]; then
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
function satan-module() {
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
    satan-index
  fi

  if [ -n "${INSTALL}" ]; then
    return satan-install "${INSTALL}"
  fi

  if [ -n "${SEARCH}" ]; then
    satan-repository-search "${SEARCH}"
  fi
}

#  Install satan modules
function satan-modules-install() {
  for module in ${MODULES[@]}; do
    satan-install "${module}"
  done
}

#  Load satan modules
function satan-modules-load() {
  local REPOSITORIES=(${SATAN_MODULES_DIRECTORY}/*)

  for module in ${MODULES[@]}; do
    for repository in ${REPOSITORIES[@]}; do

      local MODULE_DIRECTORIES=(${repository}/*)
      for module_directory in ${MODULE_DIRECTORIES[@]}; do

        local MODULE_NAME=$(basename ${module_directory})
        if [ "${module}" = "${MODULE_NAME}" ]; then

          local MODULE_FILES=(${module}/*.sh)
          for file in ${MODULE_FILES[@]}; do
            source "${file}"
          done

        fi

      done

    done
  done
}
