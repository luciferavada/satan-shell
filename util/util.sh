#  Determine if array contains a value
function contains() {
  local VALUE="${1}"; shift
  local ARRAY=("${@}")
  for value in ${ARRAY[@]}; do
    if [ "${value}" = "${VALUE}" ]; then
      return 1
    fi
    return 0
  done
}

#  Check for verbose flag
function verbose() {
  while getopts "v" option; do
    case ${option} in
      v)
        return 1
      ;;
    esac
  done
  return 0
}
