## Docker Functions
#  Default Docker machine
local DEFAULT_MACHINE="default"

#  Corolize Docker
alias docker="grc docker"

#  Colorize Docker Machine
alias docker-machine="grc docker-machine"

#  Initialize a Docker machine
function docker-init() {
  local MACHINE="${1:-${DEFAULT_MACHINE}}"
  docker-machine create --driver "virtualbox" "${MACHINE}"
}

#  Setup docker-machine environment
function docker-env() {
  local MACHINE="${1:-${DEFAULT_MACHINE}}"
  eval $(docker-machine env ${MACHINE})
}

#  Build a Dockerfile
function docker-build() {
  local TAG=${1:-"default"}
  local FILE=${2:-"Dockerfile"}
  docker build -t "${TAG}" -f "${FILE}" "$(pwd)"
}

#  Remove exited Docker containers
function docker-rm() {
  docker rm $(docker ps --all --quiet --filter "status=exited")
}

#  Remove dangling Docker images
function docker-rmi() {
  docker rmi $(docker images --all --quiet --filter "dangling=true")
}
