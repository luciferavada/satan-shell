## Toril MUD
#  Variables
local TORILMUD="${HOME}/.torilmud"


#  Login to Toril MUD
function torilmud() {
  local CONFIG="${TORILMUD}/main.tt"
  tintin -G -r "${CONFIG}" ${@}
}
