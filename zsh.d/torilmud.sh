## Toril MUD
#  Login to Toril MUD
function torilmud() {
  local TORILMUD="${HOME}/.torilmudrc"
  tintin -G -r "${TORILMUD}" ${@}
}
