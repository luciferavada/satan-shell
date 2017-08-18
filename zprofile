#  Source required files
source "${HOME}/.zsh.d/modules.conf"
source "${HOME}/.zsh.d/rc.conf"

#  Source utilities file
source "${ZSHELL_INSTALL_DIRECTORY}/util/util.sh"

#  Github API URL
local GITHUB_API_URL="https://api.github.com"

#  Environment files
local ZSHELL_FILES=("zshenv" "zprofile" "zshrc" "zlogin")

#  ZShell repositories
local ZSHELL_REPOSITORIES=("satan-core" "satan-extra" "satan-community")

#  ZShell modules index
local ZSHELL_MODULES_INDEX="${ZSHELL_INSTALL_DIRECTORY}/zsh.d/.modules.index"

#  Source environment files
function environment-load() reload() {
  for file in ${ZSHELL_FILES[@]}; do
    if [ -f "${file}" ]; then
      source "${HOME}/.${file}"
    fi
  done
}

#  Index available modules
function satan-index() {
  rm -f "${ZSHELL_MODULES_INDEX}"
  for repository in ${ZSHELL_REPOSITORIES[@]}; do
    local REPOSITORY_URL="${GITHUB_API_URL}/orgs/${repository}/repos"
    curl --silent --request "GET" "${REPOSITORY_URL}" | \
      grep "\"name\"" | \
      sed "s/.*\"name\"\:\ \"\([a-zA-Z0-9]*\)\",/${repository}\/\1/" >> \
      "${ZSHELL_MODULES_INDEX}"
  done
}
