## SSH Settings
#  SSH key files
local SSH_KEYS=("luciferavada")

#  SSH key directory
local SSH_DIR="${HOME}/.ssh"

#  List SSH keys in the SSH agent
function ssh-list-keys() {
  ssh-add -l
}

#  Find key in the SSH agent
function ssh-find-key() {
  ssh-list-keys | grep "${1}"
}

#  Add an SSH key to the SSH agent
function ssh-add-key() {
  ssh-add "${SSH_DIR}/${1}"
}

#  Add SSH keys to the SSH agent
for key in ${SSH_KEYS}; do
  if [ -z "$(ssh-find-key ${key})" ]; then
    ssh-add-key "${key}"
  fi
done
