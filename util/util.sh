#  Determine if array contains a value
function contains() {
  local VALUE="${1}"
  local ARRAY=(${@:2})
  for value in ${ARRAY[@]}; do
    if [ "${value}" = "${VALUE}" ]; then
      return 0
    fi
  done
  return 1
}

#  Check for verbose flag
function verbose() {
  while getopts "v" option; do
    case "${option}" in
      v)
        return 0
      ;;
    esac
  done
  return 1
}
