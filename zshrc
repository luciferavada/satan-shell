#  Do not modify this file

#  Github URL
local GITHUB_URL="https://github.com"

#  Github API URL
local GITHUB_API_URL="https://api.github.com"

#  Sugar modules index lock uuid
local CANDY_INDEX_LOCK_UUID=""

#  Sugar modules index lock
local CANDY_INDEX_LOCK_FILE="${HOME}/.zsh.d/.index.lock"

#  Sugar modules available index
local CANDY_INDEX_AVAILABLE="${HOME}/.zsh.d/.index.available"

#  Sugar modules installed index
local CANDY_INDEX_INSTALLED="${HOME}/.zsh.d/.index.installed"

#  Sugar modules updates index
local CANDY_INDEX_UPDATES="${HOME}/.zsh.d/.index.updates"

#  Sugar modules updates index last checked since epoch time stamp
local CANDY_INDEX_UPDATES_CHECKED="${HOME}/.zsh.d/.index.updates.checked"

#  Sugar on load hook array
local CANDY_ON_LOAD=()

#  Sugar configuration files
local CANDY_DIRECTORIES_FILE="${HOME}/.zsh.d/directories.conf"
local CANDY_MODULES_FILE="${HOME}/.zsh.d/modules.conf"
local CANDY_REPOSITORIES_FILE="${HOME}/.zsh.d/repositories.conf"
local CANDY_SETTINGS_FILE="${HOME}/.zsh.d/settings.conf"

#  Load configuration variables
function candy-load-configuration-variables \
         candy-reload-configuration-variables() {
  source "${CANDY_DIRECTORIES_FILE}"
  source "${CANDY_MODULES_FILE}"
  source "${CANDY_REPOSITORIES_FILE}"
  source "${CANDY_SETTINGS_FILE}"
}

#  Display ascii title
function candy-ascii-title() {
  echo -n "$(tput ${COLOR[reset]}; tput bold; tput setaf ${COLOR[cyan]})"
  cat "${CANDY_INSTALL_DIRECTORY}/ascii-art/title"
  echo -n "$(tput ${COLOR[reset]})"
  echo ""
}

#  Set trap for index lock file removal
function _candy-index-lock-trap() {
  trap "_candy-index-unlock \"${CANDY_INDEX_LOCK_UUID}\"; kill -INT $$" \
    SIGINT SIGHUP SIGQUIT SIGABRT SIGKILL SIGTERM
}

#  Reset trap index lock file removal
function _candy-index-lock-untrap() {
  trap - SIGINT SIGHUP SIGQUIT SIGABRT SIGKILL SIGTERM
}

#  Set trap for index lock await
function _candy-index-lock-await-trap() {
  trap "rm \"${CANDY_INDEX_LOCK_FILE}\"" SIGINT
}

#  Reset trap for index lock await
function _candy-index-lock-await-untrap() {
  trap - SIGINT
}

function _candy-index-lock-get-group() {
  local GROUP="${1}"
  cat "${CANDY_INDEX_LOCK_FILE}" | sed -E \
    "s/^([A-Fa-f0-9\-]+)\:([0-9]+)\:(.*)$/\\${GROUP}/"
}

#  Get the index lock file uuid
function _candy-index-lock-get-uuid() {
  _candy-index-lock-get-group "1"
}

#  Get the index lock file date
function _candy-index-lock-get-date() {
  _candy-index-lock-get-group "2"
}

#  Get the index lock file message
function _candy-index-lock-get-message() {
  _candy-index-lock-get-group "3"
}

#  Determine if the lock file has expired
function _candy-index-lock-check-date() {
  if [ -f "${CANDY_INDEX_LOCK_FILE}" ] && \
     [ -n "$(cat ${CANDY_INDEX_LOCK_FILE})" ]; then

    candy-reload-configuration-variables

    local -i CURRENT_TIME=$(date +%s)
    local -i LOCK_DATE=$(_candy-index-lock-get-date)
    local -i DIFFERENCE=$(( ${CURRENT_TIME} - ${LOCK_DATE} ))
    local -i REMAINING=$(( ${CANDY_INDEX_LOCK_FILE_EXPIRE} - ${DIFFERENCE} ))

    if [ ${REMAINING} -ne ${CANDY_INDEX_LOCK_FILE_EXPIRE} ]; then
      candy-message "info:reprint" "expires in: ${REMAINING}s"
    fi

    if [ ${DIFFERENCE} -ge ${CANDY_INDEX_LOCK_FILE_EXPIRE} ]; then
      candy-message "title" "Lock file expired..."
      rm "${CANDY_INDEX_LOCK_FILE}"
    fi
  fi
}

#  Determine if the lock uuid belongs to this shell instance
function _candy-index-lock-check-uuid() {
  if [ -f "${CANDY_INDEX_LOCK_FILE}" ]; then
    local LOCK_FILE_UUID=$(_candy-index-lock-get-uuid)
    if [ ! "${LOCK_FILE_UUID}" = "${CANDY_INDEX_LOCK_UUID}" ]; then
      return 1
    fi
  fi
  return 0
}

#  Wait for index lock
function _candy-index-lock-await() {
  local was_locked="false"

  if [ -f "${CANDY_INDEX_LOCK_FILE}" ]; then
    local -l LOCK_MESSAGE="$(_candy-index-lock-get-message)"
    candy-message "title" "Locked ${LOCK_MESSAGE}"
    candy-message "title" "Waiting for lock... (~/.zsh.d/.index.lock)"
    candy-message "title" "Force removal with: (CTRL+C)"
    _candy-index-lock-await-trap
  fi

  until [ ! -f "${CANDY_INDEX_LOCK_FILE}" ]; do
    was_locked="true"
    _candy-index-lock-check-date
    sleep "${CANDY_INDEX_LOCK_FILE_CHECK}"
  done

  if [ "${was_locked}" = "true" ]; then
    echo -n "\n"
  fi

  _candy-index-lock-await-untrap
}

#  Acquire the index lock
function _candy-index-lock() {
  if [ -z "${CANDY_INDEX_LOCK_UUID}" ]; then
    _candy-index-lock-await
    _candy-index-lock-trap

    local UUID=$(uuidgen)
    local -i CURRENT_TIME=$(date +%s)

    echo "${UUID}:${CURRENT_TIME}:${2}" > "${CANDY_INDEX_LOCK_FILE}"
    eval "CANDY_INDEX_LOCK_UUID=\"${UUID}\""
    eval "${1}=\"${CANDY_INDEX_LOCK_UUID}\""
  else
    eval "${1}=\"\""
  fi
}

#  Release the index lock
function _candy-index-unlock() {
  if ! _candy-index-lock-check-uuid; then
    candy-message "error" "lock removed..."
    _candy-index-lock-untrap
    kill -INT "$$"
    return 1
  fi

  local LOCK="${1}"

  if [ "${LOCK}" = "${CANDY_INDEX_LOCK_UUID}" ]; then
    _candy-index-lock-untrap
    eval "CANDY_INDEX_LOCK_UUID=\"\""
    rm "${CANDY_INDEX_LOCK_FILE}"
  fi
}

#  Add a module to the updates index file
function _candy-index-updates-write() {
  local MODULE_LINE="${1}"
  if [ -z $(grep "^${MODULE_LINE}$" "${CANDY_INDEX_UPDATES}") ]; then
    echo "${MODULE_LINE}" >> "${CANDY_INDEX_UPDATES}"
  fi
}

#  Write to the available modules index file
function _candy-index-available-write() {
  local REPOSITORY="${1}"
  grep "\"full_name\"" | sed "s/.*\"full_name\"\:\ \"\(.*\)\",/\1/" | \
    sort >> "${CANDY_INDEX_AVAILABLE}"
}

#  Add a module to the installed index file
function _candy-index-installed-write() {
  local MODULE_LINE="${1}"
  echo "${MODULE_LINE}" >> "${CANDY_INDEX_INSTALLED}"
}

#  Remove a module from the installed index file
function _candy-index-installed-remove() {
  local MODULE_LINE="${1}"
  local CANDY_INDEX_INSTALLED_TEMP=$(mktemp)
  cat "${CANDY_INDEX_INSTALLED}" | sed "/${MODULE_LINE//\//\\/}/d" > \
    "${CANDY_INDEX_INSTALLED_TEMP}"
  mv "${CANDY_INDEX_INSTALLED_TEMP}" "${CANDY_INDEX_INSTALLED}"
}

#  Remove a module from the updates index file
function _candy-index-updates-remove() {
  local MODULE_LINE="${1}"
  local CANDY_INDEX_UPDATES_TEMP=$(mktemp)
  cat "${CANDY_INDEX_UPDATES}" | sed "/${MODULE_LINE//\//\\/}/d" > \
    "${CANDY_INDEX_UPDATES_TEMP}"
  mv "${CANDY_INDEX_UPDATES_TEMP}" "${CANDY_INDEX_UPDATES}"
}

#  Determine if updates should be checked for
function _candy-index-updates-check() {
  local -i CURRENT_TIME="$(date +%s)"

  if [ ! -f "${CANDY_INDEX_UPDATES_CHECKED}" ] || \
     [ -z "$(cat ${CANDY_INDEX_UPDATES_CHECKED})" ]; then
    echo "${CURRENT_TIME}" > "${CANDY_INDEX_UPDATES_CHECKED}"
    return 0
  fi

  local -i LAST_CHECKED="$(cat ${CANDY_INDEX_UPDATES_CHECKED})"
  local -i DIFFERENCE=$(( ${CURRENT_TIME} - ${LAST_CHECKED} ))

  if [ ${DIFFERENCE} -gt ${CANDY_AUTO_UPDATE_CHECK} ]; then
    echo "${CURRENT_TIME}" > "${CANDY_INDEX_UPDATES_CHECKED}"
    return 0
  fi

  return 1
}

#  Display colorized message
function candy-message() {
  local TYPE="${1}"
  local MESSAGE="${2}"

  local SPLIT=(`echo ${TYPE//:/ }`)

  local TYPE="${SPLIT[1]}"
  local OPTION="${SPLIT[2]}"

  if [ -n "${OPTION}" ]; then
    case "${OPTION}" in
      "reprint") echo -n "\e[2K\r" ;;
      *)
        candy-message "error" "invalid message option: ${OPTION}"
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
      candy-message "error" "invalid message type: ${TYPE}"
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

#  Interpolate shell variables into source and write to destination
function candy-template() {
  local TEMPLATE_SOURCE="${1}"
  local TEMPLATE_DESTINATION="${2}"

  if [ ! -f "${TEMPLATE_SOURCE}" ]; then
    candy-message "error" "missing template: ${TEMPLATE_SOURCE}"
    return 1
  fi

  eval "echo \"$(< ${TEMPLATE_SOURCE} )\"" > "${TEMPLATE_DESTINATION}"
}

#  Find an available module
function candy-module-available-find() {
  local LOCK
  _candy-index-lock "LOCK" "Finding an available module..."

  local MODULE="${1}"

  if [ -z "${MODULE}" ]; then
    _candy-index-unlock "${LOCK}"
    return 0
  fi

  if [ -f "${CANDY_INDEX_AVAILABLE}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${CANDY_INDEX_AVAILABLE}" | grep --max-count "1" --regexp "/${1}$"
    else
      cat "${CANDY_INDEX_AVAILABLE}" | grep --max-count "1" --regexp "${1}$"
    fi
  fi

  _candy-index-unlock "${LOCK}"
}

#  Search available modules
function candy-module-available-search() {
  local LOCK
  _candy-index-lock "LOCK" "Searching available modules..."

  local MODULE="${1}"

  if [ -f "${CANDY_INDEX_AVAILABLE}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${CANDY_INDEX_AVAILABLE}" | grep --regexp "/.*${1}.*"
    else
      cat "${CANDY_INDEX_AVAILABLE}" | grep --regexp ".*${1}.*"
    fi
  fi

  _candy-index-unlock "${LOCK}"
}

#  Find an installed module
function candy-module-installed-find() {
  local LOCK
  _candy-index-lock "LOCK" "Finding an installed module..."

  local MODULE="${1}"

  if [ -z "${MODULE}" ]; then
    _candy-index-unlock "${LOCK}"
    return 0
  fi

  if [ -f "${CANDY_INDEX_INSTALLED}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${CANDY_INDEX_INSTALLED}" | grep --max-count "1" --regexp "/${1}$"
    else
      cat "${CANDY_INDEX_INSTALLED}" | grep --max-count "1" --regexp "${1}$"
    fi
  fi

  _candy-index-unlock "${LOCK}"
}

#  Search installed modules
function candy-module-installed-search() {
  local LOCK
  _candy-index-lock "LOCK" "Searching installed modules..."

  local MODULE="${1}"

  if [ -f "${CANDY_INDEX_INSTALLED}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${CANDY_INDEX_INSTALLED}" | grep  --regexp "/.*${1}.*"
    else
      cat "${CANDY_INDEX_INSTALLED}" | grep  --regexp ".*${1}.*"
    fi
  fi

  _candy-index-unlock "${LOCK}"
}

#  Index available modules
function candy-repository-index() {
  local LOCK
  _candy-index-lock "LOCK" "Indexing repositories..."

  candy-message "title" "Indexing repositories..."

  candy-reload-configuration-variables

  rm -f "${CANDY_INDEX_AVAILABLE}"

  for repository in ${CANDY_REPOSITORIES[@]}; do

    candy-message "bold" "${repository}"

    local REPOSITORY_URL="${GITHUB_API_URL}/orgs/${repository}/repos"

    curl --silent --request "GET" "${REPOSITORY_URL}" | \
      _candy-index-available-write

    if [ ! ${?} -eq 0 ]; then
      _candy-index-unlock "${LOCK}"
      return 1
    fi

  done

  _candy-index-unlock "${LOCK}"
}

#  Install a module
function candy-module-install() {
  local LOCK
  _candy-index-lock "LOCK" "Installing a module..."

  local MODULE="${1}"
  local MODULE_LINE=$(candy-module-available-find "${MODULE}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPOSITORY="${MODULE_INFO[1]}"

  candy-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    candy-message "bold" "${MODULE}"
    candy-message "error" "not found."
    _candy-index-unlock "${LOCK}"
    return 0
  fi

  candy-message "bold" "${MODULE_LINE}"

  if [ -n "$(candy-module-installed-find ${MODULE_LINE})" ]; then
    candy-message "error" "module already installed."
    _candy-index-unlock "${LOCK}"
    return 0
  fi

  git clone "${GITHUB_URL}/${MODULE_REPOSITORY}/${MODULE_NAME}.git" \
    "${CANDY_MODULES_DIRECTORY}/${MODULE_REPOSITORY}/${MODULE_NAME}"

  if [ ${?} -eq 0 ]; then
    _candy-index-installed-write "${MODULE_LINE}"
  else
    candy-message "error" "failure."
    _candy-index-unlock "${LOCK}"
    return 1
  fi

  _candy-index-unlock "${LOCK}"
}

#  Uninstall a module
function candy-module-uninstall() {
  local LOCK
  _candy-index-lock "LOCK" "Uninstalling a module..."

  local MODULE="${1}"
  local MODULE_FORCE_UNINSTALL="${2}"
  local MODULE_LINE=$(candy-module-installed-find "${MODULE}")
  local MODULE_DIRECTORY="${CANDY_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_UNINSTALL="yes"

  candy-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    candy-message "bold" "${MODULE}"
    candy-message "error" "not found."
    _candy-index-unlock "${LOCK}"
    return 0
  fi

  candy-message "bold" "${MODULE_LINE}"

  git -C "${MODULE_DIRECTORY}" diff --exit-code --no-patch

  if [ -z "${MODULE_FORCE_UNINSTALL}" ] && [ ! ${?} -eq 0 ]; then

    candy-message "error" "${MODULE_LINE} has modifications."

    echo -n "Do you want to uninstall anyway? (yes/no) "
    read MODULE_UNINSTALL

    until [ "${MODULE_UNINSTALL}" = "yes" ] || \
          [ "${MODULE_UNINSTALL}" = "no" ]; do
      echo "Do you want to uninstall anyway? (yes/no)"
      echo -n "Enter yes or no... "
      read MODULE_UNINSTALL
    done

    if [ "${MODULE_UNINSTALL}" = "yes" ]; then
      candy-message "info" "uninstalling..."
    else
      candy-message "info" "not uninstalling..."
    fi

  fi

  if [ "${MODULE_UNINSTALL}" = "yes" ]; then

    rm -rf "${MODULE_DIRECTORY}"

    if [ ${?} -eq 0 ]; then
      _candy-index-installed-remove "${MODULE_LINE}"
    else
      candy-message "error" "failure."
      _candy-index-unlock "${LOCK}"
      return 1
    fi

  fi

  _candy-index-unlock "${LOCK}"
}

#  Check a module for updates
function candy-module-update-check() {
  local LOCK
  _candy-index-lock "LOCK" "Checking a module for updates..."

  local MODULE="${1}"
  local MODULE_LINE=$(candy-module-installed-find "${MODULE}")
  local MODULE_DIRECTORY="${CANDY_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_AVAILABLE=$(candy-module-available-find "${MODULE_LINE}")

  candy-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    candy-message "bold" "${MODULE}"
    candy-message "error" "not installed."
    _candy-index-unlock "${LOCK}"
    return 0
  fi

  if [ -z "${MODULE_AVAILABLE}" ]; then
    candy-message "bold" "${MODULE}"
    candy-message "error" "not in remote repository."
    _candy-index-unlock "${LOCK}"
    return 0
  fi

  git -C "${MODULE_DIRECTORY}" fetch origin

  if [ ! ${?} -eq 0 ]; then
    candy-message "error" "failure."
    _candy-index-unlock "${LOCK}"
    return 1
  fi

  # exits non-zero if there are updates available
  git -C "${MODULE_DIRECTORY}" diff --exit-code --no-patch master origin/master

  if [ ! ${?} -eq 0 ]; then
    candy-message "bold" "${MODULE}"
    candy-message "info" "updates available."
    _candy-index-updates-write "${MODULE_LINE}"
  fi

  _candy-index-unlock "${LOCK}"
}

#  Update a module
function candy-module-update() {
  local LOCK
  _candy-index-lock "LOCK" "Updating a module..."

  local MODULE="${1}"
  local MODULE_LINE=$(candy-module-installed-find "${MODULE}")
  local MODULE_DIRECTORY="${CANDY_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_AVAILABLE=$(candy-module-available-find "${MODULE_LINE}")

  candy-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    candy-message "bold" "${MODULE}"
    candy-message "error" "not installed."
    _candy-index-unlock "${LOCK}"
    return 0
  fi

  if [ -z "${MODULE_AVAILABLE}" ]; then
    candy-message "bold" "${MODULE}"
    candy-message "error" "not in remote repository."
    _candy-index-unlock "${LOCK}"
    return 0
  fi

  candy-message "bold" "${MODULE_LINE}"

  git -C "${MODULE_DIRECTORY}" pull

  if [ ${?} -eq 0 ]; then
    _candy-index-updates-remove "${MODULE_LINE}"
  else
    candy-message "error" "failure."
    _candy-index-unlock "${LOCK}"
    return 1
  fi

  _candy-index-unlock "${LOCK}"
}

#  Load a module
function candy-module-load() {
  local LOCK
  _candy-index-lock "LOCK" "Loading a module..."

  local MODULE="${1}"
  local MODULE_LINE=$(candy-module-installed-find "${MODULE}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPOSITORY="${MODULE_INFO[1]}"
  local MODULE_DIRECTORY="${CANDY_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_FILES=(${MODULE_DIRECTORY}/*.sh)

  candy-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    candy-message "bold" "${MODULE}"
    candy-message "error" "not installed."
    _candy-index-unlock "${LOCK}"
    return 0
  fi

  # DISPLAY_MODULE_LOAD can be provided at calltime, i.e.
  # DISPLAY_MODULE_LOAD='false' candy-module-load 'some/module'
  # DISPLAY_MODULE_LOAD='false' candy-modules-enabled-load
  if [ ! "${DISPLAY_MODULE_LOAD}" = "false" ]; then
    candy-message "bold" "${MODULE_LINE}"
  fi

  for file in ${MODULE_FILES[@]}; do
    MODULE_REPOSITORY="${MODULE_REPOSITORY}" \
      MODULE_NAME="${MODULE_NAME}" \
      MODULE_DIRECTORY="${MODULE_DIRECTORY}" \
      source "${file}"
  done

  _candy-index-unlock "${LOCK}"
}

#  Find a list of available modules
function candy-modules-available-find() {
  local LOCK
  _candy-index-lock "LOCK" "Finding available modules..."

  candy-message "title" "Finding available modules..."

  for module in ${@}; do

    candy-module-available-find "${module}"

    if [ ! ${?} -eq 0 ]; then
      _candy-index-unlock "${LOCK}"
      return 1
    fi

  done

  _candy-index-unlock "${LOCK}"
}

#  Search a list of available modules
function candy-modules-available-search() {
  local LOCK
  _candy-index-lock "LOCK" "Searching available modules..."

  candy-message "title" "Searching available modules..."

  for module in ${@}; do

    candy-module-available-search "${module}"

    if [ ! ${?} -eq 0 ]; then
      _candy-index-unlock "${LOCK}"
      return 1
    fi

  done

  _candy-index-unlock "${LOCK}"
}

#  Find a list of installed modules
function candy-modules-installed-find() {
  local LOCK
  _candy-index-lock "LOCK" "Finding installed modules..."

  candy-message "title" "Finding installed modules..."

  for module in ${@}; do

    candy-module-installed-find "${module}"

    if [ ! ${?} -eq 0 ]; then
      _candy-index-unlock "${LOCK}"
      return 1
    fi

  done

  _candy-index-unlock "${LOCK}"
}

#  Search a list of installed modules
function candy-modules-installed-search() {
  local LOCK
  _candy-index-lock "LOCK" "Searching installed modules..."

  candy-message "title" "Searching installed modules..."

  for module in ${@}; do

    candy-module-installed-search "${module}"

    if [ ! ${?} -eq 0 ]; then
      _candy-index-unlock "${LOCK}"
      return 1
    fi

  done

  _candy-index-unlock "${LOCK}"
}

#  Install a list of modules
function candy-modules-install() {
  local LOCK
  _candy-index-lock "LOCK" "Installing modules..."

  candy-message "title" "Installing modules..."

  for module in ${@}; do

    candy-module-install "${module}"

    if [ ! ${?} -eq 0 ]; then
      _candy-index-unlock "${LOCK}"
      return 1
    fi

  done

  _candy-index-unlock "${LOCK}"
}

#  Uninstall a list of modules
function candy-modules-uninstall() {
  local LOCK
  _candy-index-lock "LOCK" "Uninstalling modules..."

  candy-message "title" "Uninstalling modules..."

  for module in ${@}; do

    candy-module-uninstall "${module}"

    if [ ! ${?} -eq 0 ]; then
      _candy-index-unlock "${LOCK}"
      return 1
    fi

  done

  _candy-index-unlock "${LOCK}"
}

#  Check a list of modules for updates
function candy-modules-update-check() {
  local LOCK
  _candy-index-lock "LOCK" "Checking modules for updates..."

  candy-message "title" "Checking modules for updates..."

  for module in ${@}; do

    candy-message "info:reprint" "${module}"

    candy-module-update-check "${module}"

    if [ ! ${?} -eq 0 ]; then
      _candy-index-unlock "${LOCK}"
      return 1
    fi

  done

  candy-message "info:reprint" "done"

  echo -n "\n"

  _candy-index-unlock "${LOCK}"
}

#  Update a list of modules
function candy-modules-update() {
  local LOCK
  _candy-index-lock "LOCK" "Updating modules..."

  candy-message "title" "Updating modules..."

  for module in ${@}; do

    candy-message "title" "${module}"

    candy-module-update "${module}"

    if [ ! ${?} -eq 0 ]; then
      _candy-index-unlock "${LOCK}"
      return 1
    fi

  done

  echo -n "\n"

  _candy-index-unlock "${LOCK}"
}

#  Load a list of modules
function candy-modules-load() {
  local LOCK
  _candy-index-lock "LOCK" "Loading modules..."

  candy-reload-configuration-variables

  if [ "${CANDY_DISPLAY_MODULE_LOAD}" = "true" ]; then
    candy-message "title" "Loading modules..."
  fi

  for module in ${@}; do

    candy-module-load "${module}"

    if [ ! ${?} -eq 0 ]; then
      _candy-index-unlock "${LOCK}"
      return 1
    fi

  done

  _candy-index-unlock "${LOCK}"
}

#  Install enabled modules
function candy-modules-enabled-install() {
  candy-modules-install ${CANDY_MODULES[@]}
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Check enabled modules for updates
function candy-modules-enabled-update-check() {
  candy-modules-update-check ${CANDY_MODULES[@]}
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Update enabled modules
function candy-modules-enabled-update() {
  candy-modules-update ${CANDY_MODULES[@]}
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Load enabled modules
function candy-modules-enabled-load() {
  candy-modules-load ${CANDY_MODULES[@]}
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Check all installed modules for updates
function candy-modules-installed-update-check() {
  candy-modules-update-check $(cat "${CANDY_INDEX_INSTALLED}")
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Update all installed modules
function candy-modules-installed-update() {
  candy-modules-update $(cat "${CANDY_INDEX_INSTALLED}")
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Load all installed modules
function candy-modules-installed-load() {
  candy-modules-load $(cat "${CANDY_INDEX_INSTALLED}")
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

function _candy-init() {
  local LOCK
  _candy-index-lock "LOCK" "Initializing candy..."

  candy-message "title" "Initializing candy..."

  candy-repository-index

  if [ ! ${?} -eq 0 ]; then
    _candy-index-unlock "${LOCK}"
    return 1
  fi

  candy-modules-enabled-install

  # initially create the ${CANDY_INDEX_UPDATES_CHECKED} file
  _candy-index-updates-check

  if [ ! ${?} -eq 0 ]; then
    _candy-index-unlock "${LOCK}"
    return 1
  fi

  _candy-index-unlock "${LOCK}"
}

#  Update candy and enabled modules
function _candy-update() {
  local LOCK
  _candy-index-lock "LOCK" "Updating candy..."

  candy-message "title" "Updating candy..."

  candy-reload-configuration-variables

  git -C "${CANDY_INSTALL_DIRECTORY}" pull

  if [ ! ${?} -eq 0 ]; then
    _candy-index-unlock "${LOCK}"
    return 1
  fi

  candy-repository-index

  if [ ! ${?} -eq 0 ]; then
    _candy-index-unlock "${LOCK}"
    return 1
  fi

  candy-modules-enabled-update-check

  if [ ! ${?} -eq 0 ]; then
    _candy-index-unlock "${LOCK}"
    return 1
  fi

  if [ -f "${CANDY_INDEX_UPDATES}" ]; then
    candy-modules-update "$(cat ${CANDY_INDEX_UPDATES})"
    if [ ! ${?} -eq 0 ]; then
      _candy-index-unlock "${LOCK}"
      return 1
    fi
  fi

  _candy-index-unlock "${LOCK}"
}

#  Source candy environment files
function candy-reload reload() {
  candy-message "title" "Reloading candy..."
  exec -l zsh
}

function candy-update update() {
  _candy-update
  candy-reload
}

#  Add a command with parameters to the candy-on-load hook array
function @candy-load() {
  local STRING="'"
  local i
  for (( i = 1; i <= ${#}; i++ )); do
    STRING+="\"${@[${i}]}\""
    if [ ${i} -lt ${#} ]; then
      STRING+=" "
    fi
  done
  STRING+="'"
  if [[ ! "${CANDY_ON_LOAD}" =~ "${STRING}" ]]; then
    CANDY_ON_LOAD+=("${STRING}")
  fi
}

#  Run candy on load functions
function candy-on-load() {
  for string in ${CANDY_ON_LOAD[@]}; do
    local COMMAND=(${string//\'/})
    eval "${COMMAND[@]}"
  done
}

#  Candy module manager
function candy() {
  local LOCK
  _candy-index-lock "LOCK" "By candy command..."

  local INSTALL_MODULES=""
  local UNINSTALL_MODULES=""
  local UPDATE_MODULES=""
  local LOAD_MODULES=""
  local AVALIABLE_SEARCH=""
  local INSTALLED_SEARCH=""
  local GENERATE_INDEX=""
  local ENABLED_MODULES=""
  local INSTALLED_MODULES=""
  local RELOAD_CANDY_SHELL=""
  local FORCE_UNINSTALL=""
  local DISPLAY_HELP=""

  local MODULE_LIST=()

  if [[ -z "${@}" ]]; then
    _candy-index-unlock "${LOCK}"
    candy-man
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
      "r") RELOAD_CANDY_SHELL="true" ;;
      "h") DISPLAY_HELP="true" ;;
      *) DISPLAY_HELP="true" ;;
    esac
  done

  if [ -n "${DISPLAY_HELP}" ]; then
    _candy-index-unlock "${LOCK}"
    candy-man
    return 0
  fi

  candy-reload-configuration-variables

  MODULE_LIST=(${@:${OPTIND}})

  if [ -n "${INSTALLED_MODULES}" ]; then
    MODULE_LIST=($(cat "${CANDY_INDEX_INSTALLED}"))
  fi

  if [ -n "${ENABLED_MODULES}" ]; then
    MODULE_LIST=(${CANDY_MODULES[@]})
  fi

  if [ -n "${GENERATE_INDEX}" ]; then
    candy-repository-index
    if [ ! ${?} -eq 0 ]; then
      _candy-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${INSTALL_MODULES}" ]; then
    candy-modules-install ${MODULE_LIST[@]}
    if [ ! ${?} -eq 0 ]; then
      _candy-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${UPDATE_MODULES}" ]; then
    candy-modules-enabled-update-check
    if [ -f "${CANDY_INDEX_UPDATES}" ]; then
      candy-modules-update $(cat ${CANDY_INDEX_UPDATES})
      if [ ! ${?} -eq 0 ]; then
        _candy-index-unlock "${LOCK}"
        return 1
      fi
    fi
  fi

  if [ -n "${UNINSTALL_MODULES}" ]; then
    candy-message "title" "Uninstalling modules..."
    for module in ${MODULE_LIST[@]}; do
      candy-module-uninstall "${module}" "${FORCE_UNINSTALL}"
      if [ ! ${?} -eq 0 ]; then
        _candy-index-unlock "${LOCK}"
        return 1
      fi
    done
  fi

  if [ -n "${LOAD_MODULES}" ]; then
    candy-modules-load ${MODULE_LIST[@]}
    if [ ! ${?} -eq 0 ]; then
      _candy-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${RELOAD_CANDY_SHELL}" ]; then
    candy-reload
    if [ ! ${?} -eq 0 ]; then
      _candy-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${AVAILABLE_SEARCH}" ]; then
    local MODULES=()

    if [ -n "${MODULE_LIST}" ]; then
      candy-message "title" "Searching available modules..."
      for module in ${MODULE_LIST[@]}; do
        MODULES+=($(candy-module-available-search "${module}"))
      done
    else
      candy-message "title" "Available modules..."
      MODULES=($(cat "${CANDY_INDEX_AVAILABLE}"))
    fi

    for module in ${MODULES[@]}; do
      candy-message "bold" "${module}"
    done
  fi

  if [ -n "${INSTALLED_SEARCH}" ]; then
    local MODULES=()

    if [ -n "${MODULE_LIST}" ]; then
      candy-message "title" "Searching installed modules..."
      for module in ${MODULE_LIST[@]}; do
        MODULES+=($(candy-module-installed-search "${module}"))
      done
    else
      candy-message "title" "Installed modules..."
      MODULES=($(cat "${CANDY_INDEX_INSTALLED}"))
    fi

    for module in ${MODULES[@]}; do
      candy-message "bold" "${module}"
    done
  fi

  _candy-index-unlock "${LOCK}"
}

#  Load configuration variables
candy-load-configuration-variables

#  Bootstrap the environment
source "${CANDY_INSTALL_DIRECTORY}/bootstrap.sh"
