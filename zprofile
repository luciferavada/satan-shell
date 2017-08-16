#  If the glob is empty, supress the `no matches found` error.
setopt +o nullglob

#  If zlogin doesn't exist, create it.
if [ ! -f "${HOME}/.zlogin" ]; then
  touch "${HOME}/.zlogin"
fi

#  Configuration directory
export ZSHELL_CONFIGURATION_DIRECTORY="${HOME}/.zsh.d.conf"

#  Custom directory
local ZSHELL_CUSTOM_DIRECTORY="${HOME}/.zsh.d"

#  Configuration files
local ZSHELL_CUSTOM_FILES=(${ZSHELL_CUSTOM_DIRECTORY}/*)

#  Environment files
local ZSHELL_FILES=("zshenv" "zprofile" "zshrc" "zlogin")

#  Source environment files
local function environment-load() {
  for file in ${ZSHELL_FILES}; do
    if [ -f "${file}" ]; then
      source "${HOME}/.${file}"
    fi
  done
}

#  Source configuration files
local function custom-load() {
  for file in ${ZSHELL_CUSTOM_FILES}: do
    source "${file}"
  done
}

#  Reload configuration
function reload() {
  environment-load
}

#  Check for verbose flag
local function verbose() {
  while getopts "v:" option; do
    case ${option} in
      v)
        return 1
      ;;
    esac
  done
  return 0
}

#  Modules file
local ZSHELL_MODULES_FILE="${ZSHELL_CUSTOM_DIRECTORY}/modules.conf"

#  Write default modules file
if [ ! -f "${ZSHELL_MODULES_FILE}" ]; then
  echo "#  Modules" > "${ZSHELL_MODULES_FILE}"
  echo "MODULES=(\"git\" \"ssh\")" >> "${ZSHELL_MODULES_FILE}"
fi

#  Source modules file
source "${ZSHELL_MODULES_FILE}"

#  Modules directory
export ZSHELL_MODULES_DIRECTORY="${HOME}/.zsh.d.modules"

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
  for module in ${MODULES}; do
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

#  Update installed modules
function modules-update() {
  for module in ${ZSHELL_MODULES}; do
    if [ $(verbose ${@}) ]; then
      echo "==> Updating $(basename ${module})"
    fi
    git -C "${module}" pull
  done
}

#  Load installed modules
function modules-load() {
  for module in ${ZSHELL_MODULES}; do
    local MODULE_FILES=(${module}/*.sh)
    for file in ${MODULE_FILES}; do
      if [ -f "${file}" ]; then
        if [ $(verbose ${@}) ]; then
          echo "==> Loading $(basename ${module})"
        fi
        source "${file}"
      fi
    done
  done
}

#  Uninstall modules not in the modules array
function modules-uninstall() {
  for module in ${ZSHELL_MODULES}; do
    local MODULE_PATH="${ZSHELL_MODULES_DIRECTORY}/${module}}"
    if [[ ! "${module}" =~ "${MODULES}" ]]; then
      if [ $(verbose ${@}) ]; then
        echo "==> Uninstalling $(basename ${module})"
      fi
      rm -rf "${MODULE_PATH}"
    fi
  done
}
