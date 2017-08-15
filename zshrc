## ZShell Profile
#  If the glob is empty, nullglob will remove the glob argument from the
#  list and supress the `no matches found` error.
setopt +o nullglob

#  ZShell configuration directory
local ZSHELL_FILES=(${HOME}/.zsh.d/*.sh)

# Load all files in the ZShell configuration directory
if [ -n "${ZSHELL_FILES}" ]; then
  for file in ${ZSHELL_FILES}; do
    source "${file}"
  done
fi

#  ZShell modules directory
export ZSHELL_MODULES_DIRECTORY="${HOME}/.zsh.d.modules"

#  Initialize modules array
for module in ${MODULES}; do
  local MODULE_NAME="zshell-${module}"
  local MODULE_PATH="${ZSHELL_MODULES_DIRECTORY}/${MODULE_NAME}"
  if [ ! -d "${MODULE_PATH}" ]; then
    echo "==> ${MODULE_NAME}"
    git clone "https://github.com/luciferavada/${MODULE_NAME}.git" \
      "${MODULE_PATH}"
  fi
done

#  ZShell modules arary
local ZSHELL_MODULES=(${ZSHELL_MODULES_DIRECTORY}/*)

#  Load ZShell modules
if [ -n "${ZSHELL_MODULES}" ]; then
  for module in ${ZSHELL_MODULES}; do

    local MODULE_FILES=(${module}/*.sh)

    for file in ${MODULE_FILES}; do
      if [ -f "${file}" ]; then
        source "${file}"
      fi
    done

  done
fi

#  Update ZShell modules
function modules-update() {
  if [ -n "${ZSHELL_MODULES}" ]; then
    for module in ${ZSHELL_MODULES}; do
      echo "==> $(basename ${module})"
      git -C "${module}" pull
    done
  fi
}
