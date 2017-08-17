#  Source required files
source "${HOME}/.zsh.d/rc.conf"
source "${HOME}/.zsh.d/modules.conf"

source "${ZSHELL_INSTALL_DIRECTORY}/util/util.sh"

#  Environment files
local ZSHELL_FILES=("zshenv" "zprofile" "zshrc" "zlogin")

#  Source environment files
function environment-load() {
  for file in ${ZSHELL_FILES}; do
    if [ -f "${file}" ]; then
      source "${HOME}/.${file}"
    fi
  done
}

#  Reload configuration
function reload() {
  environment-load
}

#  Configuration files
local ZSHELL_CUSTOM_FILES=(${ZSHELL_CUSTOM_DIRECTORY}/*)

#  Source configuration files
function custom-load() {
  for file in ${ZSHELL_CUSTOM_FILES[@]}; do
    source "${file}"
  done
}

#  Modules arary
local ZSHELL_MODULES=(${ZSHELL_MODULES_DIRECTORY}/*)

#  Github modules repository url
local GITHUB_REPO_URL="https://api.github.com/users/luciferavada/repos"

#  List available modules
function modules-available() {
  curl --silent --request "GET" "${GITHUB_REPO_URL}" | \
    grep "\"name\"" | \
    grep -v "configuration" | \
    sed "s/.*\"zshell-\([a-zA-Z0-9]*\)\",/\1/"
}

#  Install modules
function modules-install() {
  for module in ${MODULES[@]}; do
    local MODULE_NAME="zshell-${module}"
    local MODULE_PATH="${ZSHELL_MODULES_DIRECTORY}/${MODULE_NAME}"
    if [ ! -d "${MODULE_PATH}" ]; then
      if [ $(verbose ${@}) ]; then
        echo "==> Installing ${MODULE_NAME}"
      fi
      git clone "https://github.com/luciferavada/${MODULE_NAME}.git" \
        "${MODULE_PATH}"
    fi
  done
}

#  Uninstall modules not in the modules array
function modules-uninstall() {
  for module in ${ZSHELL_MODULES[@]}; do
    local MODULE_NAME="$(basename ${module})"
    local MODULE_ID="$(echo ${MODULE_NAME} | sed 's/zshell-\(.*\)/\1/')"
    local MODULE_PATH="${ZSHELL_MODULES_DIRECTORY}/${MODULE_NAME}}"
    if [ $(contains "${MODULE_ID}" "${MODULES[@]}") ]; then
      if [ $(verbose ${@}) ]; then
        echo "==> Uninstalling ${MODULE_NAME}"
      fi
      rm -rf "${MODULE_PATH}"
    fi
  done
}

#  Update installed modules
function modules-update() {
  for module in ${ZSHELL_MODULES[@]}; do
    local MODULE_NAME="$(basename ${module})"
    if [ $(verbose ${@}) ]; then
      echo "==> Updating ${MODULE_NAME}"
    fi
    git -C "${module}" pull
  done
}

#  Load installed modules
function modules-load() {
  for module in ${ZSHELL_MODULES[@]}; do
    local MODULE_NAME="$(basename ${module})"
    local MODULE_FILES=(${module}/*.sh)
    for file in ${MODULE_FILES}; do
      if [ -f "${file}" ]; then
        if [ $(verbose ${@}) ]; then
          echo "==> Loading ${MODULE_NAME}"
        fi
        source "${file}"
      fi
    done
  done
}
