## SSH Settings
#  SSH key files
local SSH_KEYS=("sugarush" "luciferavada")

#  Add sugarush ssh key to ssh-agent
eval $(/usr/local/bin/keychain --eval -q ${SSH_KEYS[@]})
