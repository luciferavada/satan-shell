#  Source required files
source "${HOME}/.zsh.d/modules.conf"
source "${HOME}/.zsh.d/rc.conf"

#  Source utilities file
source "${ZSHELL_INSTALL_DIRECTORY}/util/util.sh"

#  Environment files
local ZSHELL_FILES=("zshenv" "zprofile" "zshrc" "zlogin")

#  Github API URL
local GITHUB_API_URL="https://api.github.com/"

#  Core repositry URL
local CORE_REPOSITORY_URL="${GITHUB_API_URL}/users/luciferavada/repos"

#  Core modules directory
local ZSHELL_CORE_MODULES_DIRECTORY="${ZSHELL_MODULES_DIRECTORY}/core"

#  Installed core modules array
local ZSHELL_CORE_MODULES=(${ZSHELL_CORE_MODULES_DIRECTORY}/*)

#  Source environment files
function environment-load() reload() {
  for file in ${ZSHELL_FILES[@]}; do
    if [ -f "${file}" ]; then
      source "${HOME}/.${file}"
    fi
  done
}

#  List available modules
function modules-available() {
  echo "==> Available Modules"
  curl --silent --request "GET" "${CORE_REPOSITORY_URL}" | \
    grep "\"name\"" | \
    grep -v "configuration" | \
    sed "s/.*\"zshell-\([a-zA-Z0-9]*\)\",/  \1/"
}

#  Install modules
function modules-install() {
  for module_name in ${MODULES[@]}; do
    local MODULE_ID="zshell-${module_name}"
    local MODULE_PATH="${ZSHELL_CORE_MODULES_DIRCETORY}/${MODULE_ID}"
    if [ ! -d "${MODULE_PATH}" ]; then
      echo "==> Installing"
      echo "  ${module_name}"
      git clone "https://github.com/luciferavada/${MODULE_ID}.git" \
        "${MODULE_PATH}" > /dev/null
    fi
  done
}

#  Uninstall modules not in the modules array
function modules-uninstall() {
  for module_path in ${ZSHELL_CORE_MODULES[@]}; do
    local MODULE_ID="$(basename ${module_path})"
    local MODULE_NAME="$(echo ${MODULE_NAME} | sed 's/zshell-\(.*\)/\1/')"
    if [ ! $(contains "${MODULE_NAME}" "${MODULES[@]}") ]; then
      echo "==> Uninstalling"
      echo "  ${MODULE_ID}"
      rm -rf "${module_path}" > /dev/null
    fi
  done
}

#  Update installed modules
function modules-update() {
  for module_path in ${ZSHELL_CORE_MODULES[@]}; do
    local MODULE_ID="$(basename ${module})"
    if [ $(verbose "${@}") ]; then
      echo "==> Updating"
      echo "  ${MODULE_ID}"
    fi
    git -C "${module_path}" pull > /dev/null
  done
}

#  Load installed modules
function modules-load() {
  for module_name in ${MODULES[@]}; do
    local MODULE_ID="zshell-${module_name}"
    local MODULE_PATH="${ZSHELL_CORE_MODULES_DIRCETORY}/${MODULE_ID}"
    local MODULE_FILES=(${MODULE_PATH}/*.sh)
    if [ $(verbose "${@}") ]; then
      echo "==> Loading"
      echo "  ${MODULE_ID}"
    fi
    for file in ${MODULE_FILES[@]}; do
      if [ -f "${file}" ]; then
        source "${file}"
      fi
    done
  done
}
