## SSH Settings
#  SSH key files
local SSH_KEYS=("luciferavada")

#  Add sugarush ssh key to ssh-agent
eval $(/usr/local/bin/keychain --eval -q ${SSH_KEYS[@]})
