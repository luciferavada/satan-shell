## Toril MUD
#  Toril MUD configuration
local TORILMUD="${HOME}/.torilmudrc"

#  TinTin alias
alias tintin="tt++"

#  Login to Toril MUD
function torilmud() {
  tintin -G -r "${TORILMUD}" ${@}
}
