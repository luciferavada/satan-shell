## TTY Settings
#  Enable forward history search (CTRL+s)
stty -ixon

# ZShell configuration files
local FILES=("zshenv" "zprofile" "zshrc" "zlogin")

#  Reload ZShell configuration files
function reload() {
  for file in ${FILES}; do
    if [ -f "${file}" ]; then
      source "${HOME}/.${file}"
      echo "source ${HOME}/.${file}"
    fi
  done
}
