#  Do not modify this file

#  Github URL
local GITHUB_URL="https://github.com"

#  Github API URL
local GITHUB_API_URL="https://api.github.com"

#  Sugar modules index lock uuid
local SATAN_INDEX_LOCK_UUID=""

#  Sugar modules index lock
local SATAN_INDEX_LOCK_FILE="${HOME}/.zsh.d/.index.lock"

#  Sugar modules available index
local SATAN_INDEX_AVAILABLE="${HOME}/.zsh.d/.index.available"

#  Sugar modules installed index
local SATAN_INDEX_INSTALLED="${HOME}/.zsh.d/.index.installed"

#  Sugar modules updates index
local SATAN_INDEX_UPDATES="${HOME}/.zsh.d/.index.updates"

#  Sugar modules updates index last checked since epoch time stamp
local SATAN_INDEX_UPDATES_CHECKED="${HOME}/.zsh.d/.index.updates.checked"

#  Sugar on load hook array
local SATAN_ON_LOAD=()

#  Sugar configuration files
local SATAN_DIRECTORIES_FILE="${HOME}/.zsh.d/directories.conf"
local SATAN_MODULES_FILE="${HOME}/.zsh.d/modules.conf"
local SATAN_REPOSITORIES_FILE="${HOME}/.zsh.d/repositories.conf"
local SATAN_SETTINGS_FILE="${HOME}/.zsh.d/settings.conf"

#  Load configuration variables
function satan-load-configuration-variables \
         satan-reload-configuration-variables() {
  source "${SATAN_DIRECTORIES_FILE}"
  source "${SATAN_MODULES_FILE}"
  source "${SATAN_REPOSITORIES_FILE}"
  source "${SATAN_SETTINGS_FILE}"
}

#  Display ascii skull
function satan-ascii-skull() {
  echo ""
  echo -n "$(tput ${COLOR[reset]}; tput bold; tput setaf ${COLOR[black]})"
  cat "${SATAN_INSTALL_DIRECTORY}/ascii-art/skull"
  echo -n "$(tput ${COLOR[reset]})"
  echo ""
}

#  Display ascii demon
function satan-ascii-demon demon() {
  echo ""
  echo -n "$(tput ${COLOR[reset]}; tput setaf ${COLOR[magenta]})"
  cat "${SATAN_INSTALL_DIRECTORY}/ascii-art/demon"
  echo -n "$(tput ${COLOR[reset]})"
  echo ""
}

#  Display ascii title
function satan-ascii-title() {
  echo -n "$(tput ${COLOR[reset]}; tput bold; tput setaf ${COLOR[red]})"
  cat "${SATAN_INSTALL_DIRECTORY}/ascii-art/title"
  echo -n "$(tput ${COLOR[reset]})"
  echo ""
}

#  Display credit
function satan-credit() {
  echo ""
  echo -n "$(tput ${COLOR[reset]}; tput bold; tput setaf ${COLOR[black]})"
  echo "   By: Lucifer Avada | Github: luciferavada | Twitter: @luciferavada"
  echo -n "$(tput ${COLOR[reset]})"
  echo ""
}

#  Display ascii header
function satan-ascii-header() {
  satan-ascii-skull
  satan-credit
  satan-ascii-title
}

#  Set trap for index lock file removal
function _satan-index-lock-trap() {
  trap "_satan-index-unlock \"${SATAN_INDEX_LOCK_UUID}\"; kill -INT $$" \
    SIGINT SIGHUP SIGQUIT SIGABRT SIGKILL SIGTERM
}

#  Reset trap index lock file removal
function _satan-index-lock-untrap() {
  trap - SIGINT SIGHUP SIGQUIT SIGABRT SIGKILL SIGTERM
}

#  Set trap for index lock await
function _satan-index-lock-await-trap() {
  trap "rm \"${SATAN_INDEX_LOCK_FILE}\"" SIGINT
}

#  Reset trap for index lock await
function _satan-index-lock-await-untrap() {
  trap - SIGINT
}

function _satan-index-lock-get-group() {
  cat "${SATAN_INDEX_LOCK_FILE}" | sed -E \
    "s/^([A-Fa-f0-9\-]+)\:([0-9]+)\:(.*)$/\\${1}/"
}

#  Get the index lock file uuid
function _satan-index-lock-get-uuid() {
  _satan-index-lock-get-group "1"
}

#  Get the index lock file date
function _satan-index-lock-get-date() {
  _satan-index-lock-get-group "2"
}

#  Get the index lock file message
function _satan-index-lock-get-message() {
  _satan-index-lock-get-group "3"
}

#  Determine if the lock file has expired
function _satan-index-lock-check-date() {
  if [ -f "${SATAN_INDEX_LOCK_FILE}" ] && \
     [ -n "$(cat ${SATAN_INDEX_LOCK_FILE})" ]; then

    satan-reload-configuration-variables

    local -i CURRENT_TIME=$(date +%s)
    local -i LOCK_DATE=$(_satan-index-lock-get-date)
    local -i DIFFERENCE=$(( ${CURRENT_TIME} - ${LOCK_DATE} ))
    local -i REMAINING=$(( ${SATAN_INDEX_LOCK_FILE_EXPIRE} - ${DIFFERENCE} ))

    if [ ${REMAINING} -ne ${SATAN_INDEX_LOCK_FILE_EXPIRE} ]; then
      satan-message "reprint" "expires in: ${REMAINING}s"
    fi

    if [ ${DIFFERENCE} -ge ${SATAN_INDEX_LOCK_FILE_EXPIRE} ]; then
      satan-message "title" "Lock file expired..."
      rm "${SATAN_INDEX_LOCK_FILE}"
    fi
  fi
}

#  Determine if the lock uuid belongs to this shell instance
function _satan-index-lock-check-uuid() {
  if [ -f "${SATAN_INDEX_LOCK_FILE}" ]; then
    local LOCK_FILE_UUID=$(_satan-index-lock-get-uuid)
    if [ ! "${LOCK_FILE_UUID}" = "${SATAN_INDEX_LOCK_UUID}" ]; then
      return 1
    fi
  fi
  return 0
}

#  Wait for index lock
function _satan-index-lock-await() {
  if [ -f "${SATAN_INDEX_LOCK_FILE}" ]; then
    local -l LOCK_MESSAGE="$(_satan-index-lock-get-message)"
    satan-message "title" "Locked ${LOCK_MESSAGE}"
    satan-message "title" "Waiting for lock... (~/.zsh.d/.index.lock)"
    satan-message "title" "Force removal with: (CTRL+C)"
    _satan-index-lock-await-trap
  fi

  until [ ! -f "${SATAN_INDEX_LOCK_FILE}" ]; do
    _satan-index-lock-check-date
    sleep "${SATAN_INDEX_LOCK_FILE_CHECK}"
  done

  _satan-index-lock-await-untrap
}

#  Acquire the index lock
function _satan-index-lock() {
  if [ -z "${SATAN_INDEX_LOCK_UUID}" ]; then
    _satan-index-lock-await
    _satan-index-lock-trap

    local UUID=$(uuidgen)
    local -i CURRENT_TIME=$(date +%s)

    echo "${UUID}:${CURRENT_TIME}:${2}" > "${SATAN_INDEX_LOCK_FILE}"
    eval "SATAN_INDEX_LOCK_UUID=\"${UUID}\""
    eval "${1}=\"${SATAN_INDEX_LOCK_UUID}\""
  else
    eval "${1}=\"\""
  fi
}

#  Release the index lock
function _satan-index-unlock() {
  if ! _satan-index-lock-check-uuid; then
    satan-message "error" "lock removed..."
    _satan-index-lock-untrap
    kill -INT "$$"
    return 1
  fi

  local LOCK="${1}"

  if [ "${LOCK}" = "${SATAN_INDEX_LOCK_UUID}" ]; then
    _satan-index-lock-untrap
    eval "SATAN_INDEX_LOCK_UUID=\"\""
    rm "${SATAN_INDEX_LOCK_FILE}"
  fi
}

#  Add a module to the updates index file
function _satan-index-updates-write() {
  local MODULE_LINE="${1}"
  if [ -z $(grep "^${MODULE_LINE}$" "${SATAN_INDEX_UPDATES}") ]; then
    echo "${MODULE_LINE}" >> "${SATAN_INDEX_UPDATES}"
  fi
}

#  Write to the available modules index file
function _satan-index-available-write() {
  local REPOSITORY="${1}"
  grep "\"full_name\"" | sed "s/.*\"full_name\"\:\ \"\(.*\)\",/\1/" | \
    sort >> "${SATAN_INDEX_AVAILABLE}"
}

#  Add a module to the installed index file
function _satan-index-installed-write() {
  local MODULE_LINE="${1}"
  echo "${MODULE_LINE}" >> "${SATAN_INDEX_INSTALLED}"
}

#  Remove a module from the installed index file
function _satan-index-installed-remove() {
  local MODULE_LINE="${1}"
  local SATAN_INDEX_INSTALLED_TEMP=$(mktemp)
  cat "${SATAN_INDEX_INSTALLED}" | sed "/${MODULE_LINE//\//\\/}/d" > \
    "${SATAN_INDEX_INSTALLED_TEMP}"
  mv "${SATAN_INDEX_INSTALLED_TEMP}" "${SATAN_INDEX_INSTALLED}"
}

#  Remove a function from the updates index file
function _satan-index-updates-remove() {
  local MODULE_LINE="${1}"
  local SATAN_INDEX_UPDATES_TEMP=$(mktemp)
  cat "${SATAN_INDEX_UPDATES}" | sed "/${MODULE_LINE//\//\\/}/d" > \
    "${SATAN_INDEX_UPDATES_TEMP}"
  mv "${SATAN_INDEX_UPDATES_TEMP}" "${SATAN_INDEX_UPDATES}"
}

#  Determine if updates should be checked for
function _satan-index-updates-check() {
  local -i CURRENT_TIME="$(date +%s)"

  if [ ! -f "${SATAN_INDEX_UPDATES_CHECKED}" ] || \
     [ -z "$(cat ${SATAN_INDEX_UPDATES_CHECKED})" ]; then
    echo "${CURRENT_TIME}" > "${SATAN_INDEX_UPDATES_CHECKED}"
    return 0
  fi

  local -i LAST_CHECKED="$(cat ${SATAN_INDEX_UPDATES_CHECKED})"
  local -i DIFFERENCE=$(( ${CURRENT_TIME} - ${LAST_CHECKED} ))

  if [ ${DIFFERENCE} -gt ${SATAN_AUTO_UPDATE_CHECK} ]; then
    echo "${CURRENT_TIME}" > "${SATAN_INDEX_UPDATES_CHECKED}"
    return 0
  fi

  return 1
}

#  Display colorized message
function satan-message() {
  local TYPE="${1}"
  local MESSAGE="${2}"

  local SPLIT=(`echo ${TYPE//:/ }`)

  local TYPE="${SPLIT[1]}"
  local OPTION="${SPLIT[2]}"

  if [ -n "${OPTION}" ]; then
    case "${OPTION}" in
      "reprint") echo -n "\e[2K\r" ;;
      *)
        satan-message "error" "invalid message option: ${OPTION}"
        return 1
        ;;
    esac
  fi

  case "${TYPE}" in
    "title") echo -n "$(tput bold; tput setaf ${COLOR[green]})--> " ;;
    "bold") echo -n "$(tput bold; tput setaf ${COLOR[magenta]})==> " ;;
    "error") echo -n "$(tput bold; tput setaf ${COLOR[red]})--> " ;;
    "info") echo -n "$(tput ${COLOR[reset]})--> " ;;
    *)
      satan-message "error" "invalid message type: ${TYPE}"
      return 1
      ;;
  esac

  case "${OPTION}" in
    "reprint") echo -n "${MESSAGE}" ;;
    *) echo "${MESSAGE}" ;;
  esac

  echo -n "$(tput ${COLOR[reset]})"

  return 0
}

#
function satan-template() {
  local TEMPLATE_SOURCE="${1}"
  local TEMPLATE_DESTINATION="${2}"

  if [ ! -f "${TEMPLATE_SOURCE}" ]; then
    satan-message "error" "missing template: ${TEMPLATE_SOURCE}"
    return 1
  fi

  eval "echo \"$(< ${TEMPLATE_SOURCE} )\"" > "${TEMPLATE_DESTINATION}"
}

#  Find an available module
function satan-module-available-find() {
  local LOCK
  _satan-index-lock "LOCK" "Finding an available module..."

  local MODULE="${1}"

  if [ -z "${MODULE}" ]; then
    _satan-index-unlock "${LOCK}"
    return 0
  fi

  if [ -f "${SATAN_INDEX_AVAILABLE}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SATAN_INDEX_AVAILABLE}" | grep --max-count "1" --regexp "/${1}$"
    else
      cat "${SATAN_INDEX_AVAILABLE}" | grep --max-count "1" --regexp "${1}$"
    fi
  fi

  _satan-index-unlock "${LOCK}"
}

#  Search available modules
function satan-module-available-search() {
  local LOCK
  _satan-index-lock "LOCK" "Searching available modules..."

  local MODULE="${1}"

  if [ -f "${SATAN_INDEX_AVAILABLE}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SATAN_INDEX_AVAILABLE}" | grep --regexp "/.*${1}.*"
    else
      cat "${SATAN_INDEX_AVAILABLE}" | grep --regexp ".*${1}.*"
    fi
  fi

  _satan-index-unlock "${LOCK}"
}

#  Find an installed module
function satan-module-installed-find() {
  local LOCK
  _satan-index-lock "LOCK" "Finding an installed module..."

  local MODULE="${1}"

  if [ -z "${MODULE}" ]; then
    _satan-index-unlock "${LOCK}"
    return 0
  fi

  if [ -f "${SATAN_INDEX_INSTALLED}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SATAN_INDEX_INSTALLED}" | grep --max-count "1" --regexp "/${1}$"
    else
      cat "${SATAN_INDEX_INSTALLED}" | grep --max-count "1" --regexp "${1}$"
    fi
  fi

  _satan-index-unlock "${LOCK}"
}

#  Search installed modules
function satan-module-installed-search() {
  local LOCK
  _satan-index-lock "LOCK" "Searching installed modules..."

  local MODULE="${1}"

  if [ -f "${SATAN_INDEX_INSTALLED}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SATAN_INDEX_INSTALLED}" | grep  --regexp "/.*${1}.*"
    else
      cat "${SATAN_INDEX_INSTALLED}" | grep  --regexp ".*${1}.*"
    fi
  fi

  _satan-index-unlock "${LOCK}"
}

#  Index available modules
function satan-repository-index() {
  local LOCK
  _satan-index-lock "LOCK" "Indexing repositories..."

  satan-message "title" "Indexing repositories..."

  satan-reload-configuration-variables

  rm -f "${SATAN_INDEX_AVAILABLE}"

  for repository in ${SATAN_REPOSITORIES[@]}; do

    satan-message "bold" "${repository}"

    local REPOSITORY_URL="${GITHUB_API_URL}/orgs/${repository}/repos"

    curl --silent --request "GET" "${REPOSITORY_URL}" | \
      _satan-index-available-write

    if [ ! ${?} -eq 0 ]; then
      _satan-index-unlock "${LOCK}"
      return 1
    fi

  done

  _satan-index-unlock "${LOCK}"
}

#  Install a module
function satan-module-install() {
  local LOCK
  _satan-index-lock "LOCK" "Installing a module..."

  local MODULE="${1}"
  local MODULE_LINE=$(satan-module-available-find "${MODULE}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPOSITORY="${MODULE_INFO[1]}"

  satan-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    satan-message "bold" "${MODULE}"
    satan-message "error" "not found."
    _satan-index-unlock "${LOCK}"
    return 0
  fi

  satan-message "bold" "${MODULE_LINE}"

  if [ -n "$(satan-module-installed-find ${MODULE_LINE})" ]; then
    satan-message "error" "module already installed."
    _satan-index-unlock "${LOCK}"
    return 0
  fi

  git clone "${GITHUB_URL}/${MODULE_REPOSITORY}/${MODULE_NAME}.git" \
    "${SATAN_MODULES_DIRECTORY}/${MODULE_REPOSITORY}/${MODULE_NAME}"

  if [ ${?} -eq 0 ]; then
    _satan-index-installed-write "${MODULE_LINE}"
  else
    satan-message "error" "failure."
    _satan-index-unlock "${LOCK}"
    return 1
  fi

  _satan-index-unlock "${LOCK}"
}

#  Uninstall a module
function satan-module-uninstall() {
  local LOCK
  _satan-index-lock "LOCK" "Uninstalling a module..."

  local MODULE="${1}"
  local MODULE_FORCE_UNINSTALL="${2}"
  local MODULE_LINE=$(satan-module-installed-find "${MODULE}")
  local MODULE_DIRECTORY="${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_UNINSTALL="yes"

  satan-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    satan-message "bold" "${MODULE}"
    satan-message "error" "not found."
    _satan-index-unlock "${LOCK}"
    return 0
  fi

  satan-message "bold" "${MODULE_LINE}"

  git -C "${MODULE_DIRECTORY}" diff --exit-code --no-patch

  if [ -z "${MODULE_FORCE_UNINSTALL}" ] && [ ! ${?} -eq 0 ]; then

    satan-message "error" "${MODULE_LINE} has modifications."

    echo -n "Do you want to uninstall anyway? (yes/no) "
    read MODULE_UNINSTALL

    until [ "${MODULE_UNINSTALL}" = "yes" ] || \
          [ "${MODULE_UNINSTALL}" = "no" ]; do
      echo "Do you want to uninstall anyway? (yes/no)"
      echo -n "Enter yes or no... "
      read MODULE_UNINSTALL
    done

    if [ "${MODULE_UNINSTALL}" = "yes" ]; then
      satan-message "info" "uninstalling..."
    else
      satan-message "info" "not uninstalling..."
    fi

  fi

  if [ "${MODULE_UNINSTALL}" = "yes" ]; then

    rm -rf "${MODULE_DIRECTORY}"

    if [ ${?} -eq 0 ]; then
      _satan-index-installed-remove "${MODULE_LINE}"
    else
      satan-message "error" "failure."
      _satan-index-unlock "${LOCK}"
      return 1
    fi

  fi

  _satan-index-unlock "${LOCK}"
}

#  Check a module for updates
function satan-module-update-check() {
  local LOCK
  _satan-index-lock "LOCK" "Checking a module for updates..."

  local MODULE="${1}"
  local MODULE_LINE=$(satan-module-installed-find "${MODULE}")
  local MODULE_DIRECTORY="${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_AVAILABLE=$(satan-module-available-find "${MODULE_LINE}")

  satan-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    satan-message "bold" "${MODULE}"
    satan-message "error" "not installed."
    _satan-index-unlock "${LOCK}"
    return 0
  fi

  if [ -z "${MODULE_AVAILABLE}" ]; then
    satan-message "bold" "${MODULE}"
    satan-message "error" "not in remote repository."
    _satan-index-unlock "${LOCK}"
    return 0
  fi

  git -C "${MODULE_DIRECTORY}" fetch origin

  if [ ! ${?} -eq 0 ]; then
    satan-message "error" "failure."
    _satan-index-unlock "${LOCK}"
    return 1
  fi

  # exits non-zero if there are updates available
  git -C "${MODULE_DIRECTORY}" diff --exit-code --no-patch master origin/master

  if [ ! ${?} -eq 0 ]; then
    satan-message "bold" "${MODULE}"
    satan-message "info" "updates available."
    _satan-index-updates-write "${MODULE_LINE}"
  fi

  _satan-index-unlock "${LOCK}"
}

#  Update a module
function satan-module-update() {
  local LOCK
  _satan-index-lock "LOCK" "Updating a module..."

  local MODULE="${1}"
  local MODULE_LINE=$(satan-module-installed-find "${MODULE}")
  local MODULE_DIRECTORY="${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_AVAILABLE=$(satan-module-available-find "${MODULE_LINE}")

  satan-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    satan-message "bold" "${MODULE}"
    satan-message "error" "not installed."
    _satan-index-unlock "${LOCK}"
    return 0
  fi

  if [ -z "${MODULE_AVAILABLE}" ]; then
    satan-message "bold" "${MODULE}"
    satan-message "error" "not in remote repository."
    _satan-index-unlock "${LOCK}"
    return 0
  fi

  satan-message "bold" "${MODULE_LINE}"

  git -C "${MODULE_DIRECTORY}" pull

  if [ ${?} -eq 0 ]; then
    _satan-index-updates-remove "${MODULE_LINE}"
  else
    satan-message "error" "failure."
    _satan-index-unlock "${LOCK}"
    return 1
  fi

  _satan-index-unlock "${LOCK}"
}

#  Load a module
function satan-module-load() {
  local LOCK
  _satan-index-lock "LOCK" "Loading a module..."

  local MODULE="${1}"
  local MODULE_LINE=$(satan-module-installed-find "${MODULE}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPOSITORY="${MODULE_INFO[1]}"
  local MODULE_DIRECTORY="${SATAN_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_FILES=(${MODULE_DIRECTORY}/*.sh)

  satan-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    satan-message "bold" "${MODULE}"
    satan-message "error" "not installed."
    _satan-index-unlock "${LOCK}"
    return 0
  fi

  if [ "${SATAN_DISPLAY_MODULE_LOAD}" = "true" ]; then
    satan-message "bold" "${MODULE_LINE}"
  fi

  for file in ${MODULE_FILES[@]}; do
    MODULE_REPOSITORY="${MODULE_REPOSITORY}" \
      MODULE_NAME="${MODULE_NAME}" \
      MODULE_DIRECTORY="${MODULE_DIRECTORY}" \
      source "${file}"
  done

  _satan-index-unlock "${LOCK}"
}

#  Find a list of available modules
function satan-modules-available-find() {
  local LOCK
  _satan-index-lock "LOCK" "Finding available modules..."

  satan-message "title" "Finding available modules..."

  for module in ${@}; do

    satan-module-available-find "${module}"

    if [ ! ${?} -eq 0 ]; then
      _satan-index-unlock "${LOCK}"
      return 1
    fi

  done

  _satan-index-unlock "${LOCK}"
}

#  Search a list of available modules
function satan-modules-available-search() {
  local LOCK
  _satan-index-lock "LOCK" "Searching available modules..."

  satan-message "title" "Searching available modules..."

  for module in ${@}; do

    satan-module-available-search "${module}"

    if [ ! ${?} -eq 0 ]; then
      _satan-index-unlock "${LOCK}"
      return 1
    fi

  done

  _satan-index-unlock "${LOCK}"
}

#  Find a list of installed modules
function satan-modules-installed-find() {
  local LOCK
  _satan-index-lock "LOCK" "Finding installed modules..."

  satan-message "title" "Finding installed modules..."

  for module in ${@}; do

    satan-module-installed-find "${module}"

    if [ ! ${?} -eq 0 ]; then
      _satan-index-unlock "${LOCK}"
      return 1
    fi

  done

  _satan-index-unlock "${LOCK}"
}

#  Search a list of installed modules
function satan-modules-installed-search() {
  local LOCK
  _satan-index-lock "LOCK" "Searching installed modules..."

  satan-message "title" "Searching installed modules..."

  for module in ${@}; do

    satan-module-installed-search "${module}"

    if [ ! ${?} -eq 0 ]; then
      _satan-index-unlock "${LOCK}"
      return 1
    fi

  done

  _satan-index-unlock "${LOCK}"
}

#  Install a list of modules
function satan-modules-install() {
  local LOCK
  _satan-index-lock "LOCK" "Installing modules..."

  satan-message "title" "Installing modules..."

  for module in ${@}; do

    satan-module-install "${module}"

    if [ ! ${?} -eq 0 ]; then
      _satan-index-unlock "${LOCK}"
      return 1
    fi

  done

  _satan-index-unlock "${LOCK}"
}

#  Uninstall a list of modules
function satan-modules-uninstall() {
  local LOCK
  _satan-index-lock "LOCK" "Uninstalling modules..."

  satan-message "title" "Uninstalling modules..."

  for module in ${@}; do

    satan-module-uninstall "${module}"

    if [ ! ${?} -eq 0 ]; then
      _satan-index-unlock "${LOCK}"
      return 1
    fi

  done

  _satan-index-unlock "${LOCK}"
}

#  Check a list of modules for updates
function satan-modules-update-check() {
  local LOCK
  _satan-index-lock "LOCK" "Checking for module updates..."

  satan-message "title" "Checking for module updates..."

  for module in ${@}; do

    satan-module-update-check "${module}"

    if [ ! ${?} -eq 0 ]; then
      _satan-index-unlock "${LOCK}"
      return 1
    fi

  done

  _satan-index-unlock "${LOCK}"
}

#  Update a list of modules
function satan-modules-update() {
  local LOCK
  _satan-index-lock "LOCK" "Updating modules..."

  satan-message "title" "Updating modules..."

  for module in ${@}; do

    satan-module-update "${module}"

    if [ ! ${?} -eq 0 ]; then
      _satan-index-unlock "${LOCK}"
      return 1
    fi

  done

  _satan-index-unlock "${LOCK}"
}

#  Load a list of modules
function satan-modules-load() {
  local LOCK
  _satan-index-lock "LOCK" "Loading modules..."

  satan-reload-configuration-variables

  if [ "${SATAN_DISPLAY_MODULE_LOAD}" = "true" ]; then
    satan-message "title" "Loading modules..."
  fi

  for module in ${@}; do

    satan-module-load "${module}"

    if [ ! ${?} -eq 0 ]; then
      _satan-index-unlock "${LOCK}"
      return 1
    fi

  done

  _satan-index-unlock "${LOCK}"
}

#  Install enabled modules
function satan-modules-enabled-install() {
  satan-modules-install ${SATAN_MODULES[@]}
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Check enabled modules for updates
function satan-modules-enabled-update-check() {
  satan-modules-update-check ${SATAN_MODULES[@]}
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Update enabled modules
function satan-modules-enabled-update() {
  satan-modules-update ${SATAN_MODULES[@]}
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Load enabled modules
function satan-modules-enabled-load() {
  satan-modules-load ${SATAN_MODULES[@]}
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Check all installed modules for updates
function satan-modules-installed-update-check() {
  satan-modules-update-check $(cat "${SATAN_INDEX_INSTALLED}")
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Update all installed modules
function satan-modules-installed-update() {
  satan-modules-update $(cat "${SATAN_INDEX_INSTALLED}")
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Load all installed modules
function satan-modules-installed-load() {
  satan-modules-load $(cat "${SATAN_INDEX_INSTALLED}")
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

function _satan-init() {
  local LOCK
  _satan-index-lock "LOCK" "Initializing satan-shell..."

  satan-message "title" "Initializing satan-shell..."

  satan-repository-index

  if [ ! ${?} -eq 0 ]; then
    _satan-index-unlock "${LOCK}"
    return 1
  fi

  satan-modules-enabled-install

  # initially create the ${SATAN_INDEX_UPDATES_CHECKED} file
  _satan-index-updates-check

  if [ ! ${?} -eq 0 ]; then
    _satan-index-unlock "${LOCK}"
    return 1
  fi

  _satan-index-unlock "${LOCK}"
}

#  Update satan-shell and enabled modules
function _satan-update() {
  local LOCK
  _satan-index-lock "LOCK" "Updating satan-shell..."

  satan-message "title" "Updating satan-shell..."

  satan-reload-configuration-variables

  git -C "${SATAN_INSTALL_DIRECTORY}" pull

  if [ ! ${?} -eq 0 ]; then
    _satan-index-unlock "${LOCK}"
    return 1
  fi

  satan-repository-index

  if [ ! ${?} -eq 0 ]; then
    _satan-index-unlock "${LOCK}"
    return 1
  fi

  satan-modules-enabled-update-check

  if [ ! ${?} -eq 0 ]; then
    _satan-index-unlock "${LOCK}"
    return 1
  fi

  if [ -f "${SATAN_INDEX_UPDATES}" ]; then
    satan-modules-update "$(cat ${SATAN_INDEX_UPDATES})"
    if [ ! ${?} -eq 0 ]; then
      _satan-index-unlock "${LOCK}"
      return 1
    fi
  fi

  _satan-index-unlock "${LOCK}"
}

#  Source satan-shell environment files
function satan-reload reload() {
  satan-message "title" "Reloading satan-shell..."
  exec -l zsh
}

function satan-update update() {
  _satan-update
  satan-reload
}

#  Add a command with parameters to the satan-on-load hook array
function @satan-load() {
  local STRING="'"
  local i
  for (( i = 1; i <= ${#}; i++ )); do
    STRING+="\"${@[${i}]}\""
    if [ ${i} -lt ${#} ]; then
      STRING+=" "
    fi
  done
  STRING+="'"
  if [[ ! "${SATAN_ON_LOAD}" =~ "${STRING}" ]]; then
    SATAN_ON_LOAD+=("${STRING}")
  fi
}

#  Run satan on load functions
function satan-on-load() {
  for string in ${SATAN_ON_LOAD[@]}; do
    local COMMAND=(${string//\'/})
    eval "${COMMAND[@]}"
  done
}

#  Sugar module manager
function satan() {
  local LOCK
  _satan-index-lock "LOCK" "By satan command..."

  local INSTALL_MODULES=""
  local UNINSTALL_MODULES=""
  local UPDATE_MODULES=""
  local LOAD_MODULES=""
  local AVALIABLE_SEARCH=""
  local INSTALLED_SEARCH=""
  local GENERATE_INDEX=""
  local ENABLED_MODULES=""
  local INSTALLED_MODULES=""
  local RELOAD_SATAN_SHELL=""
  local FORCE_UNINSTALL=""
  local DISPLAY_HELP=""

  local MODULE_LIST=()

  if [[ -z "${@}" ]]; then
    _satan-index-unlock "${LOCK}"
    satan-man
    return 0
  fi

  while getopts ":SRULQXyaifrh" option; do
    case $option in
      "S") INSTALL_MODULES="true" ;;
      "R") UNINSTALL_MODULES="true" ;;
      "U") UPDATE_MODULES="true" ;;
      "L") LOAD_MODULES="true" ;;
      "Q") AVAILABLE_SEARCH="true" ;;
      "X") INSTALLED_SEARCH="true" ;;
      "y") GENERATE_INDEX="true" ;;
      "a") ENABLED_MODULES="true" ;;
      "i") INSTALLED_MODULES="true" ;;
      "f") FORCE_UNINSTALL="true" ;;
      "r") RELOAD_SATAN_SHELL="true" ;;
      "h") DISPLAY_HELP="true" ;;
      *) DISPLAY_HELP="true" ;;
    esac
  done

  if [ -n "${DISPLAY_HELP}" ]; then
    _satan-index-unlock "${LOCK}"
    satan-man
    return 0
  fi

  satan-reload-configuration-variables

  MODULE_LIST=(${@:${OPTIND}})

  if [ -n "${INSTALLED_MODULES}" ]; then
    MODULE_LIST=($(cat "${SATAN_INDEX_INSTALLED}"))
  fi

  if [ -n "${ENABLED_MODULES}" ]; then
    MODULE_LIST=(${SATAN_MODULES[@]})
  fi

  if [ -n "${GENERATE_INDEX}" ]; then
    satan-repository-index
    if [ ! ${?} -eq 0 ]; then
      _satan-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${INSTALL_MODULES}" ]; then
    satan-modules-install ${MODULE_LIST[@]}
    if [ ! ${?} -eq 0 ]; then
      _satan-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${UPDATE_MODULES}" ]; then
    satan-modules-enabled-update-check
    satan-modules-update $(cat ${SATAN_INDEX_UPDATES})
    if [ ! ${?} -eq 0 ]; then
      _satan-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${UNINSTALL_MODULES}" ]; then
    satan-message "title" "Uninstalling modules..."
    for module in ${MODULE_LIST[@]}; do
      satan-module-uninstall "${module}" "${FORCE_UNINSTALL}"
      if [ ! ${?} -eq 0 ]; then
        _satan-index-unlock "${LOCK}"
        return 1
      fi
    done
  fi

  if [ -n "${LOAD_MODULES}" ]; then
    satan-modules-load ${MODULE_LIST[@]}
    if [ ! ${?} -eq 0 ]; then
      _satan-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${RELOAD_SATAN_SHELL}" ]; then
    satan-reload
    if [ ! ${?} -eq 0 ]; then
      _satan-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${AVAILABLE_SEARCH}" ]; then
    local MODULES=()

    if [ -n "${MODULE_LIST}" ]; then
      satan-message "title" "Searching available modules..."
      for module in ${MODULE_LIST[@]}; do
        MODULES+=($(satan-module-available-search "${module}"))
      done
    else
      satan-message "title" "Available modules..."
      MODULES=($(cat "${SATAN_INDEX_AVAILABLE}"))
    fi

    for module in ${MODULES[@]}; do
      satan-message "bold" "${module}"
    done
  fi

  if [ -n "${INSTALLED_SEARCH}" ]; then
    local MODULES=()

    if [ -n "${MODULE_LIST}" ]; then
      satan-message "title" "Searching installed modules..."
      for module in ${MODULE_LIST[@]}; do
        MODULES+=($(satan-module-installed-search "${module}"))
      done
    else
      satan-message "title" "Installed modules..."
      MODULES=($(cat "${SATAN_INDEX_INSTALLED}"))
    fi

    for module in ${MODULES[@]}; do
      satan-message "bold" "${module}"
    done
  fi

  _satan-index-unlock "${LOCK}"
}
