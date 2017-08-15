## ZShell Environment
#  ZShell configuration files
local ZSHELL_FILES=("zshenv" "zprofile" "zshrc" "zlogin")

#  Reload ZShell configuration files
function reload() {
  for file in ${ZSHELL_FILES}; do
    if [ -f "${file}" ]; then
      echo "source ${HOME}/.${file}"
      source "${HOME}/.${file}"
    fi
  done
}
