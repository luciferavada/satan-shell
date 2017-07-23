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
