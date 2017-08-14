## ZShell Settings
#  If the glob is empty, nullglob will remove the glob argument from the
#  list and supress the `no matches found` error.
setopt +o nullglob


## ZShell Configuration
#  ZShell configuration directory
local ZSHRC_DIRECTORY=(${HOME}/.zsh.d/*)

# Load all files in the ZShell configuration directory
if [ -n "${ZSHRC_DIRECTORY}" ]; then
  for file in ${ZSHRC_DIRECTORY}; do
    source "${file}"
  done
fi

#  ZShell modules directory
export ZSH_MODULES_DIRECTORY="${HOME}/.zsh.d.modules"

#  ZShell modules arary
local ZSH_MODULES=(${ZSH_MODULES_DIRECTORY}/*)

#  Load ZShell modules
if [ -n "${ZSH_MODULES}" ]; then
  for module in ${ZSH_MODULES}; do

    local MODULE_FILES=(${module}/*)

    for file in ${MODULE_FILES}; do
      if [ -f "${file}" ]; then
        source "${file}"
      fi
    done

  done
fi
