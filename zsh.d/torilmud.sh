## Toril MUD
#  Variables
local TORILMUD_HOME="${HOME}/.torilmud"


#  Login to Toril MUD
function torilmud() {
  local CONFIG="${TORILMUD_HOME}/main.tt"
  echo "config: ${CONFIG}"
  local SESSION="#session toril torilmud.org 9999"
  tintin -G -r "${CONFIG}" -e "${SESSION}" ${@}
}
