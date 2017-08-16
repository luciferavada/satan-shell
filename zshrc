#  Modules
export MODULES=(
  "docker" "git" "golang" "ls" "python" "redtube" "ssh" "tintin" "tmux" "tor"
)

#  Load configuation files
configuration-load

#  Uninstall modules not in the modules arary
modules-uninstall

#  Update installed modules
modules-update

#  Install and load modules
modules-install
modules-load
