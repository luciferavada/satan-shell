#  Do not modify this file

#  Github URL
local GITHUB_URL="https://github.com"

#  Github API URL
local GITHUB_API_URL="https://api.github.com"

#  Sugar modules index lock uuid
local SUGAR_INDEX_LOCK_UUID=""

#  Sugar modules index lock
local SUGAR_INDEX_LOCK_FILE="${HOME}/.zsh.d/.index.lock"

#  Sugar modules available index
local SUGAR_INDEX_AVAILABLE="${HOME}/.zsh.d/.index.available"

#  Sugar modules installed index
local SUGAR_INDEX_INSTALLED="${HOME}/.zsh.d/.index.installed"

#  Sugar modules updates index
local SUGAR_INDEX_UPDATES="${HOME}/.zsh.d/.index.updates"

#  Sugar modules updates index last checked since epoch time stamp
local SUGAR_INDEX_UPDATES_CHECKED="${HOME}/.zsh.d/.index.updates.checked"

#  Sugar on load hook array
local SUGAR_ON_LOAD=()

#  Sugar configuration files
local SUGAR_DIRECTORIES_FILE="${HOME}/.zsh.d/directories.conf"
local SUGAR_MODULES_FILE="${HOME}/.zsh.d/modules.conf"
local SUGAR_REPOSITORIES_FILE="${HOME}/.zsh.d/repositories.conf"
local SUGAR_SETTINGS_FILE="${HOME}/.zsh.d/settings.conf"

#  Load configuration variables
function sugar-load-configuration-variables \
         sugar-reload-configuration-variables() {
  source "${SUGAR_DIRECTORIES_FILE}"
  source "${SUGAR_MODULES_FILE}"
  source "${SUGAR_REPOSITORIES_FILE}"
  source "${SUGAR_SETTINGS_FILE}"
}

#  Display ascii art
function sugar-ascii-art() {
  echo ""
  echo -n "$(tput ${COLOR[reset]}; tput bold; tput setaf ${COLOR[black]})"
  cat "${SUGAR_INSTALL_DIRECTORY}/ascii-art"
  echo -n "$(tput ${COLOR[reset]})"
  echo ""
}

#  Display ascii title
function sugar-ascii-title() {
  echo -n "$(tput ${COLOR[reset]}; tput bold; tput setaf ${COLOR[red]})"
  cat "${SUGAR_INSTALL_DIRECTORY}/ascii-title"
  echo -n "$(tput ${COLOR[reset]})"
  echo ""
}

#  Display credit
function sugar-credit() {
  echo ""
  echo -n "$(tput ${COLOR[reset]}; tput bold; tput setaf ${COLOR[black]})"
  echo "      By: Paul Severance | Github: psev | Twitter: @iamnapalmbrain"
  echo -n "$(tput ${COLOR[reset]})"
  echo ""
}

#  Display ascii header
function sugar-ascii-header() {
  sugar-ascii-art
  sugar-credit
  sugar-ascii-title
}

#  Set trap for index lock file removal
function _sugar-index-lock-trap() {
  trap "_sugar-index-unlock \"${SUGAR_INDEX_LOCK_UUID}\"; kill -INT $$" \
    SIGINT SIGHUP SIGQUIT SIGABRT SIGKILL SIGTERM
}

#  Reset trap index lock file removal
function _sugar-index-lock-untrap() {
  trap - SIGINT SIGHUP SIGQUIT SIGABRT SIGKILL SIGTERM
}

#  Set trap for index lock await
function _sugar-index-lock-await-trap() {
  trap "rm \"${SUGAR_INDEX_LOCK_FILE}\"" SIGINT
}

#  Reset trap for index lock await
function _sugar-index-lock-await-untrap() {
  trap - SIGINT
}

function _sugar-index-lock-get-group() {
  cat "${SUGAR_INDEX_LOCK_FILE}" | sed -E \
    "s/^([A-Fa-f0-9\-]+)\:([0-9]+)\:(.*)$/\\${1}/"
}

#  Get the index lock file uuid
function _sugar-index-lock-get-uuid() {
  _sugar-index-lock-get-group "1"
}

#  Get the index lock file date
function _sugar-index-lock-get-date() {
  _sugar-index-lock-get-group "2"
}

#  Get the index lock file message
function _sugar-index-lock-get-message() {
  _sugar-index-lock-get-group "3"
}

#  Determine if the lock file has expired
function _sugar-index-lock-check-date() {
  if [ -f "${SUGAR_INDEX_LOCK_FILE}" ] && \
     [ -n "$(cat ${SUGAR_INDEX_LOCK_FILE})" ]; then

    sugar-reload-configuration-variables

    local -i CURRENT_TIME=$(date +%s)
    local -i LOCK_DATE=$(_sugar-index-lock-get-date)
    local -i DIFFERENCE=$(( ${CURRENT_TIME} - ${LOCK_DATE} ))
    local -i WAIT=$(( ${SUGAR_INDEX_LOCK_FILE_EXPIRE} - ${DIFFERENCE} ))
    local -i DISPLAY=$(( ${WAIT} % ${SUGAR_DISPLAY_INDEX_LOCK_FILE_EVERY} ))

    if [ "${SUGAR_DISPLAY_INDEX_LOCK_FILE_WAIT}" = "true" ] && \
       [ ${WAIT} -ne ${SUGAR_INDEX_LOCK_FILE_EXPIRE} ] && \
       [ ${WAIT} -ge 0 ] && [ ${DISPLAY} -eq 0 ]; then
      sugar-message "info" "expires in: ${WAIT}s"
    fi

    if [ ${DIFFERENCE} -ge ${SUGAR_INDEX_LOCK_FILE_EXPIRE} ]; then
      sugar-message "title" "Lock file expired..."
      rm "${SUGAR_INDEX_LOCK_FILE}"
    fi
  fi
}

#  Determine if the lock uuid belongs to this shell instance
function _sugar-index-lock-check-uuid() {
  if [ -f "${SUGAR_INDEX_LOCK_FILE}" ]; then
    local LOCK_FILE_UUID=$(_sugar-index-lock-get-uuid)
    if [ ! "${LOCK_FILE_UUID}" = "${SUGAR_INDEX_LOCK_UUID}" ]; then
      return 1
    fi
  fi
  return 0
}

#  Wait for index lock
function _sugar-index-lock-await() {
  if [ -f "${SUGAR_INDEX_LOCK_FILE}" ]; then
    local -l LOCK_MESSAGE="$(_sugar-index-lock-get-message)"
    sugar-message "title" "Locked ${LOCK_MESSAGE}"
    sugar-message "title" "Waiting for lock... (~/.zsh.d/.index.lock)"
    sugar-message "title" "Force removal with: (CTRL+C)"
    _sugar-index-lock-await-trap
  fi
  until [ ! -f "${SUGAR_INDEX_LOCK_FILE}" ]; do
    _sugar-index-lock-check-date
    sleep 1
  done
  _sugar-index-lock-await-untrap
}

#  Acquire the index lock
function _sugar-index-lock() {
  if [ -z "${SUGAR_INDEX_LOCK_UUID}" ]; then
    _sugar-index-lock-await
    _sugar-index-lock-trap

    local UUID=$(uuidgen)
    local -i CURRENT_TIME=$(date +%s)

    echo "${UUID}:${CURRENT_TIME}:${2}" > "${SUGAR_INDEX_LOCK_FILE}"
    eval "SUGAR_INDEX_LOCK_UUID=\"${UUID}\""
    eval "${1}=\"${SUGAR_INDEX_LOCK_UUID}\""
  else
    eval "${1}=\"\""
  fi
}

#  Release the index lock
function _sugar-index-unlock() {
  if ! _sugar-index-lock-check-uuid; then
    sugar-message "error" "lock removed..."
    _sugar-index-lock-untrap
    kill -INT "$$"
    return 1
  fi

  local LOCK="${1}"

  if [ "${LOCK}" = "${SUGAR_INDEX_LOCK_UUID}" ]; then
    _sugar-index-lock-untrap
    eval "SUGAR_INDEX_LOCK_UUID=\"\""
    rm "${SUGAR_INDEX_LOCK_FILE}"
  fi
}

#  Add a module to the updates index file
function _sugar-index-updates-write() {
  local MODULE_LINE="${1}"
  if [ -z $(grep "^${MODULE_LINE}$" "${SUGAR_INDEX_UPDATES}") ]; then
    echo "${MODULE_LINE}" >> "${SUGAR_INDEX_UPDATES}"
  fi
}

#  Write to the available modules index file
function _sugar-index-available-write() {
  local REPOSITORY="${1}"
  grep "\"full_name\"" | sed "s/.*\"full_name\"\:\ \"\(.*\)\",/\1/" | \
    sort >> "${SUGAR_INDEX_AVAILABLE}"
}

#  Add a module to the installed index file
function _sugar-index-installed-write() {
  local MODULE_LINE="${1}"
  echo "${MODULE_LINE}" >> "${SUGAR_INDEX_INSTALLED}"
}

#  Remove a module from the installed index file
function _sugar-index-installed-remove() {
  local MODULE_LINE="${1}"
  local SUGAR_INDEX_INSTALLED_TEMP=$(mktemp)
  cat "${SUGAR_INDEX_INSTALLED}" | sed "/${MODULE_LINE//\//\\/}/d" > \
    "${SUGAR_INDEX_INSTALLED_TEMP}"
  mv "${SUGAR_INDEX_INSTALLED_TEMP}" "${SUGAR_INDEX_INSTALLED}"
}

#  Remove a function from the updates index file
function _sugar-index-updates-remove() {
  local MODULE_LINE="${1}"
  local SUGAR_INDEX_UPDATES_TEMP=$(mktemp)
  cat "${SUGAR_INDEX_UPDATES}" | sed "/${MODULE_LINE//\//\\/}/d" > \
    "${SUGAR_INDEX_UPDATES_TEMP}"
  mv "${SUGAR_INDEX_UPDATES_TEMP}" "${SUGAR_INDEX_UPDATES}"
}

#  Determine if updates should be checked for
function _sugar-index-updates-check() {
  local -i CURRENT_TIME="$(date +%s)"

  if [ ! -f "${SUGAR_INDEX_UPDATES_CHECKED}" ] || \
     [ -z "$(cat ${SUGAR_INDEX_UPDATES_CHECKED})" ]; then
    echo "${CURRENT_TIME}" > "${SUGAR_INDEX_UPDATES_CHECKED}"
    return 0
  fi

  local -i LAST_CHECKED="$(cat ${SUGAR_INDEX_UPDATES_CHECKED})"
  local -i DIFFERENCE=$(( ${CURRENT_TIME} - ${LAST_CHECKED} ))

  if [ ${DIFFERENCE} -gt ${SUGAR_AUTO_UPDATE_CHECK} ]; then
    echo "${CURRENT_TIME}" > "${SUGAR_INDEX_UPDATES_CHECKED}"
    return 0
  fi

  return 1
}

#  Display colorized message
function sugar-message() {
  local TYPE="${1}"
  local MESSAGE="${2}"

  case "${TYPE}" in
    "title") echo -n "$(tput bold; tput setaf ${COLOR[green]})--> " ;;
    "bold") echo -n "$(tput bold; tput setaf ${COLOR[magenta]})==> " ;;
    "info") echo -n "$(tput ${COLOR[reset]})--> " ;;
    "error") echo -n "$(tput bold; tput setaf ${COLOR[red]})--> " ;;
  esac

  echo "${MESSAGE}"
  echo -n "$(tput ${COLOR[reset]})"
}

#  Find an available module
function sugar-module-available-find() {
  local LOCK
  _sugar-index-lock "LOCK" "Finding an available module..."

  local MODULE="${1}"
  if [ -z "${MODULE}" ]; then
    _sugar-index-unlock "${LOCK}"
    return 0
  fi
  if [ -f "${SUGAR_INDEX_AVAILABLE}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SUGAR_INDEX_AVAILABLE}" | grep --max-count "1" --regexp "/${1}$"
    else
      cat "${SUGAR_INDEX_AVAILABLE}" | grep --max-count "1" --regexp "${1}$"
    fi
  fi

  _sugar-index-unlock "${LOCK}"
}

#  Search available modules
function sugar-module-available-search() {
  local LOCK
  _sugar-index-lock "LOCK" "Searching available modules..."

  local MODULE="${1}"
  if [ -f "${SUGAR_INDEX_AVAILABLE}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SUGAR_INDEX_AVAILABLE}" | grep --regexp "/.*${1}.*"
    else
      cat "${SUGAR_INDEX_AVAILABLE}" | grep --regexp ".*${1}.*"
    fi
  fi

  _sugar-index-unlock "${LOCK}"
}

#  Find an installed module
function sugar-module-installed-find() {
  local LOCK
  _sugar-index-lock "LOCK" "Finding an installed module..."

  local MODULE="${1}"
  if [ -z "${MODULE}" ]; then
    _sugar-index-unlock "${LOCK}"
    return 0
  fi
  if [ -f "${SUGAR_INDEX_INSTALLED}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SUGAR_INDEX_INSTALLED}" | grep --max-count "1" --regexp "/${1}$"
    else
      cat "${SUGAR_INDEX_INSTALLED}" | grep --max-count "1" --regexp "${1}$"
    fi
  fi

  _sugar-index-unlock "${LOCK}"
}

#  Search installed modules
function sugar-module-installed-search() {
  local LOCK
  _sugar-index-lock "LOCK" "Searching installed modules..."

  local MODULE="${1}"
  if [ -f "${SUGAR_INDEX_INSTALLED}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SUGAR_INDEX_INSTALLED}" | grep  --regexp "/.*${1}.*"
    else
      cat "${SUGAR_INDEX_INSTALLED}" | grep  --regexp ".*${1}.*"
    fi
  fi

  _sugar-index-unlock "${LOCK}"
}

#  Index available modules
function sugar-repository-index() {
  local LOCK
  _sugar-index-lock "LOCK" "Indexing repositories..."

  sugar-message "title" "Indexing repositories..."

  sugar-reload-configuration-variables

  rm -f "${SUGAR_INDEX_AVAILABLE}"

  for repository in ${SUGAR_REPOSITORIES[@]}; do

    sugar-message "bold" "${repository}"

    local REPOSITORY_URL="${GITHUB_API_URL}/orgs/${repository}/repos"

    curl --silent --request "GET" "${REPOSITORY_URL}" | \
      _sugar-index-available-write

    if [ ! ${?} -eq 0 ]; then
      _sugar-index-unlock "${LOCK}"
      return 1
    fi

  done

  _sugar-index-unlock "${LOCK}"
}

#  Install a module
function sugar-module-install() {
  local LOCK
  _sugar-index-lock "LOCK" "Installing a module..."

  local MODULE="${1}"
  local MODULE_LINE=$(sugar-module-available-find "${MODULE}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPOSITORY="${MODULE_INFO[1]}"

  sugar-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    sugar-message "bold" "${MODULE}"
    sugar-message "error" "not found."
    _sugar-index-unlock "${LOCK}"
    return 0
  fi

  sugar-message "bold" "${MODULE_LINE}"

  if [ -n "$(sugar-module-installed-find ${MODULE_LINE})" ]; then
    sugar-message "error" "module already installed."
    _sugar-index-unlock "${LOCK}"
    return 0
  fi

  git clone "${GITHUB_URL}/${MODULE_REPOSITORY}/${MODULE_NAME}.git" \
    "${SUGAR_MODULES_DIRECTORY}/${MODULE_REPOSITORY}/${MODULE_NAME}"

  if [ ${?} -eq 0 ]; then
    _sugar-index-installed-write "${MODULE_LINE}"
  else
    sugar-message "error" "failure."
    _sugar-index-unlock "${LOCK}"
    return 1
  fi

  _sugar-index-unlock "${LOCK}"
}

#  Uninstall a module
function sugar-module-uninstall() {
  local LOCK
  _sugar-index-lock "LOCK" "Uninstalling a module..."

  local MODULE="${1}"
  local MODULE_FORCE_UNINSTALL="${2}"
  local MODULE_LINE=$(sugar-module-installed-find "${MODULE}")
  local MODULE_DIRECTORY="${SUGAR_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_UNINSTALL="yes"

  sugar-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    sugar-message "bold" "${MODULE}"
    sugar-message "error" "not found."
    _sugar-index-unlock "${LOCK}"
    return 0
  fi

  sugar-message "bold" "${MODULE_LINE}"

  git -C "${MODULE_DIRECTORY}" diff --exit-code --no-patch

  if [ -z "${MODULE_FORCE_UNINSTALL}" ] && [ ! ${?} -eq 0 ]; then

    sugar-message "error" "${MODULE_LINE} has modifications."

    echo -n "Do you want to uninstall anyway? (yes/no) "
    read MODULE_UNINSTALL

    until [ "${MODULE_UNINSTALL}" = "yes" ] || \
          [ "${MODULE_UNINSTALL}" = "no" ]; do
      echo "Do you want to uninstall anyway? (yes/no)"
      echo -n "Enter yes or no... "
      read MODULE_UNINSTALL
    done

    if [ "${MODULE_UNINSTALL}" = "yes" ]; then
      sugar-message "info" "uninstalling..."
    else
      sugar-message "info" "not uninstalling..."
    fi

  fi

  if [ "${MODULE_UNINSTALL}" = "yes" ]; then

    rm -rf "${MODULE_DIRECTORY}"

    if [ ${?} -eq 0 ]; then
      _sugar-index-installed-remove "${MODULE_LINE}"
    else
      sugar-message "error" "failure."
      _sugar-index-unlock "${LOCK}"
      return 1
    fi

  fi

  _sugar-index-unlock "${LOCK}"
}

#  Check a module for updates
function sugar-module-update-check() {
  local LOCK
  _sugar-index-lock "LOCK" "Checking a module for updates..."

  local MODULE="${1}"
  local MODULE_LINE=$(sugar-module-installed-find "${MODULE}")
  local MODULE_DIRECTORY="${SUGAR_MODULES_DIRECTORY}/${MODULE_LINE}"

  local MODULE_AVAILABLE=$(sugar-module-available-find "${MODULE_LINE}")

  sugar-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    sugar-message "bold" "${MODULE}"
    sugar-message "error" "not installed."
    _sugar-index-unlock "${LOCK}"
    return 0
  fi

  if [ -z "${MODULE_AVAILABLE}" ]; then
    sugar-message "bold" "${MODULE}"
    sugar-message "error" "not in remote repository."
    _sugar-index-unlock "${LOCK}"
    return 0
  fi

  git -C "${MODULE_DIRECTORY}" fetch origin

  if [ ! ${?} -eq 0 ]; then
    sugar-message "error" "failure."
    _sugar-index-unlock "${LOCK}"
    return 1
  fi

  # exits non-zero if there are updates available
  git -C "${MODULE_DIRECTORY}" diff --exit-code --no-patch master origin/master

  if [ ! ${?} -eq 0 ]; then
    sugar-message "bold" "${MODULE}"
    sugar-message "info" "updates available."
    _sugar-index-updates-write "${MODULE_LINE}"
  fi

  _sugar-index-unlock "${LOCK}"
}

#  Update a module
function sugar-module-update() {
  local LOCK
  _sugar-index-lock "LOCK" "Updating a module..."

  local MODULE="${1}"
  local MODULE_LINE=$(sugar-module-installed-find "${MODULE}")
  local MODULE_DIRECTORY="${SUGAR_MODULES_DIRECTORY}/${MODULE_LINE}"

  local MODULE_AVAILABLE=$(sugar-module-available-find "${MODULE_LINE}")

  sugar-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    sugar-message "bold" "${MODULE}"
    sugar-message "error" "not installed."
    _sugar-index-unlock "${LOCK}"
    return 0
  fi

  if [ -z "${MODULE_AVAILABLE}" ]; then
    sugar-message "bold" "${MODULE}"
    sugar-message "error" "not in remote repository."
    _sugar-index-unlock "${LOCK}"
    return 0
  fi

  sugar-message "bold" "${MODULE_LINE}"

  git -C "${MODULE_DIRECTORY}" pull

  if [ ${?} -eq 0 ]; then
    _sugar-index-updates-remove "${MODULE_LINE}"
  else
    sugar-message "error" "failure."
    _sugar-index-unlock "${LOCK}"
    return 1
  fi

  _sugar-index-unlock "${LOCK}"
}

#  Load a module
function sugar-module-load() {
  local LOCK
  _sugar-index-lock "LOCK" "Loading a module..."

  local MODULE="${1}"
  local MODULE_LINE=$(sugar-module-installed-find "${MODULE}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPOSITORY="${MODULE_INFO[1]}"

  local MODULE_DIRECTORY="${SUGAR_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_FILES=(${MODULE_DIRECTORY}/*.sh)

  sugar-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    sugar-message "bold" "${MODULE}"
    sugar-message "error" "not installed."
    _sugar-index-unlock "${LOCK}"
    return 0
  fi

  if [ "${SUGAR_DISPLAY_MODULE_LOAD}" = "true" ]; then
    sugar-message "bold" "${MODULE_LINE}"
  fi

  for file in ${MODULE_FILES[@]}; do
    MODULE_REPOSITORY="${MODULE_REPOSITORY}" MODULE_NAME="${MODULE_NAME}" \
      MODULE_DIRECTORY="${MODULE_DIRECTORY}" \
      source "${file}"
  done

  _sugar-index-unlock "${LOCK}"
}

#  Find a list of available modules
function sugar-modules-available-find() {
  local LOCK
  _sugar-index-lock "LOCK" "Finding available modules..."

  sugar-message "title" "Finding available modules..."

  for module in ${@}; do

    sugar-module-available-find "${module}"

    if [ ! ${?} -eq 0 ]; then
      _sugar-index-unlock "${LOCK}"
      return 1
    fi

  done

  _sugar-index-unlock "${LOCK}"
}

#  Search a list of available modules
function sugar-modules-available-search() {
  local LOCK
  _sugar-index-lock "LOCK" "Searching available modules..."

  sugar-message "title" "Searching available modules..."

  for module in ${@}; do

    sugar-module-available-search "${module}"

    if [ ! ${?} -eq 0 ]; then
      _sugar-index-unlock "${LOCK}"
      return 1
    fi

  done

  _sugar-index-unlock "${LOCK}"
}

#  Find a list of installed modules
function sugar-modules-installed-find() {
  local LOCK
  _sugar-index-lock "LOCK" "Finding installed modules..."

  sugar-message "title" "Finding installed modules..."

  for module in ${@}; do

    sugar-module-installed-find "${module}"

    if [ ! ${?} -eq 0 ]; then
      _sugar-index-unlock "${LOCK}"
      return 1
    fi

  done

  _sugar-index-unlock "${LOCK}"
}

#  Search a list of installed modules
function sugar-modules-installed-search() {
  local LOCK
  _sugar-index-lock "LOCK" "Searching installed modules..."

  sugar-message "title" "Searching installed modules..."

  for module in ${@}; do

    sugar-module-installed-search "${module}"

    if [ ! ${?} -eq 0 ]; then
      _sugar-index-unlock "${LOCK}"
      return 1
    fi

  done

  _sugar-index-unlock "${LOCK}"
}

#  Install a list of modules
function sugar-modules-install() {
  local LOCK
  _sugar-index-lock "LOCK" "Installing modules..."

  sugar-message "title" "Installing modules..."

  for module in ${@}; do

    sugar-module-install "${module}"

    if [ ! ${?} -eq 0 ]; then
      _sugar-index-unlock "${LOCK}"
      return 1
    fi

  done

  _sugar-index-unlock "${LOCK}"
}

#  Uninstall a list of modules
function sugar-modules-uninstall() {
  local LOCK
  _sugar-index-lock "LOCK" "Uninstalling modules..."

  sugar-message "title" "Uninstalling modules..."

  for module in ${@}; do

    sugar-module-uninstall "${module}"

    if [ ! ${?} -eq 0 ]; then
      _sugar-index-unlock "${LOCK}"
      return 1
    fi

  done

  _sugar-index-unlock "${LOCK}"
}

#  Check a list of modules for updates
function sugar-modules-update-check() {
  local LOCK
  _sugar-index-lock "LOCK" "Checking for module updates..."

  sugar-message "title" "Checking for module updates..."

  for module in ${@}; do

    sugar-module-update-check "${module}"

    if [ ! ${?} -eq 0 ]; then
      _sugar-index-unlock "${LOCK}"
      return 1
    fi

  done

  _sugar-index-unlock "${LOCK}"
}

#  Update a list of modules
function sugar-modules-update() {
  local LOCK
  _sugar-index-lock "LOCK" "Updating modules..."

  sugar-message "title" "Updating modules..."

  for module in ${@}; do

    sugar-module-update "${module}"

    if [ ! ${?} -eq 0 ]; then
      _sugar-index-unlock "${LOCK}"
      return 1
    fi

  done

  _sugar-index-unlock "${LOCK}"
}

#  Load a list of modules
function sugar-modules-load() {
  local LOCK
  _sugar-index-lock "LOCK" "Loading modules..."

  sugar-reload-configuration-variables

  if [ "${SUGAR_DISPLAY_MODULE_LOAD}" = "true" ]; then
    sugar-message "title" "Loading modules..."
  fi

  for module in ${@}; do

    sugar-module-load "${module}"

    if [ ! ${?} -eq 0 ]; then
      _sugar-index-unlock "${LOCK}"
      return 1
    fi

  done

  _sugar-index-unlock "${LOCK}"
}

#  Install enabled modules
function sugar-modules-enabled-install() {
  sugar-modules-install ${SUGAR_MODULES[@]}
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Check enabled modules for updates
function sugar-modules-enabled-update-check() {
  sugar-modules-update-check ${SUGAR_MODULES[@]}
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Update enabled modules
function sugar-modules-enabled-update() {
  sugar-modules-update ${SUGAR_MODULES[@]}
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Load enabled modules
function sugar-modules-enabled-load() {
  sugar-modules-load ${SUGAR_MODULES[@]}
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Check all installed modules for updates
function sugar-modules-installed-update-check() {
  sugar-modules-update-check $(cat "${SUGAR_INDEX_INSTALLED}")
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Update all installed modules
function sugar-modules-installed-update() {
  sugar-modules-update $(cat "${SUGAR_INDEX_INSTALLED}")
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Load all installed modules
function sugar-modules-installed-load() {
  sugar-modules-load $(cat "${SUGAR_INDEX_INSTALLED}")
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

function _sugar-init() {
  local LOCK
  _sugar-index-lock "LOCK" "Initializing sugar-shell..."

  sugar-message "title" "Initializing sugar-shell..."

  sugar-repository-index

  if [ ! ${?} -eq 0 ]; then
    _sugar-index-unlock "${LOCK}"
    return 1
  fi

  sugar-modules-enabled-install

  # initially create the ${SUGAR_INDEX_UPDATES_CHECKED} file
  _sugar-index-updates-check

  if [ ! ${?} -eq 0 ]; then
    _sugar-index-unlock "${LOCK}"
    return 1
  fi

  _sugar-index-unlock "${LOCK}"
}

#  Update sugar-shell and enabled modules
function _sugar-update() {
  local LOCK
  _sugar-index-lock "LOCK" "Updating sugar-shell..."

  sugar-message "title" "Updating sugar-shell..."

  sugar-reload-configuration-variables

  git -C "${SUGAR_INSTALL_DIRECTORY}" pull

  if [ ! ${?} -eq 0 ]; then
    _sugar-index-unlock "${LOCK}"
    return 1
  fi

  sugar-repository-index

  if [ ! ${?} -eq 0 ]; then
    _sugar-index-unlock "${LOCK}"
    return 1
  fi

  sugar-modules-enabled-update-check

  if [ ! ${?} -eq 0 ]; then
    _sugar-index-unlock "${LOCK}"
    return 1
  fi

  if [ -f "${SUGAR_INDEX_UPDATES}" ]; then
    sugar-modules-update "$(cat ${SUGAR_INDEX_UPDATES})"
    if [ ! ${?} -eq 0 ]; then
      _sugar-index-unlock "${LOCK}"
      return 1
    fi
  fi

  _sugar-index-unlock "${LOCK}"
}

#  Source sugar-shell environment files
function sugar-reload reload() {
  sugar-message "title" "Reloading sugar-shell..."
  exec -l zsh
}

function sugar-update update() {
  _sugar-update
  sugar-reload
}

#  Add a command with parameters to the sugar-on-load hook array
function @sugar-load() {
  local STRING="'"
  local i
  for (( i = 1; i <= ${#}; i++ )); do
    STRING+="\"${@[${i}]}\""
    if [ ${i} -lt ${#} ]; then
      STRING+=" "
    fi
  done
  STRING+="'"
  if [[ ! "${SUGAR_ON_LOAD}" =~ "${STRING}" ]]; then
    SUGAR_ON_LOAD+=("${STRING}")
  fi
}

#  Run sugar on load functions
function sugar-on-load() {
  for string in ${SUGAR_ON_LOAD[@]}; do
    local COMMAND=(${string//\'/})
    eval "${COMMAND[@]}"
  done
}

#  Sugar module manager
function sugar() {
  local LOCK
  _sugar-index-lock "LOCK" "By sugar command..."

  local INSTALL_MODULES=""
  local UNINSTALL_MODULES=""
  local UPDATE_MODULES=""
  local LOAD_MODULES=""
  local AVALIABLE_SEARCH=""
  local INSTALLED_SEARCH=""
  local GENERATE_INDEX=""
  local ENABLED_MODULES=""
  local INSTALLED_MODULES=""
  local RELOAD_SUGAR_SHELL=""
  local FORCE_UNINSTALL=""
  local DISPLAY_HELP=""

  local MODULE_LIST=()

  if [[ -z "${@}" ]]; then
    _sugar-index-unlock "${LOCK}"
    sugar-man
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
      "r") RELOAD_SUGAR_SHELL="true" ;;
      "h") DISPLAY_HELP="true" ;;
      *) DISPLAY_HELP="true" ;;
    esac
  done

  if [ -n "${DISPLAY_HELP}" ]; then
    _sugar-index-unlock "${LOCK}"
    sugar-man
    return 0
  fi

  sugar-reload-configuration-variables

  MODULE_LIST=(${@:${OPTIND}})

  if [ -n "${INSTALLED_MODULES}" ]; then
    MODULE_LIST=($(cat "${SUGAR_INDEX_INSTALLED}"))
  fi

  if [ -n "${ENABLED_MODULES}" ]; then
    MODULE_LIST=(${SUGAR_MODULES[@]})
  fi

  if [ -n "${GENERATE_INDEX}" ]; then
    sugar-repository-index
    if [ ! ${?} -eq 0 ]; then
      _sugar-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${INSTALL_MODULES}" ]; then
    sugar-modules-install ${MODULE_LIST[@]}
    if [ ! ${?} -eq 0 ]; then
      _sugar-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${UPDATE_MODULES}" ]; then
    sugar-modules-enabled-update-check
    sugar-modules-update $(cat ${SUGAR_INDEX_UPDATES})
    if [ ! ${?} -eq 0 ]; then
      _sugar-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${UNINSTALL_MODULES}" ]; then
    sugar-message "title" "Uninstalling modules..."
    for module in ${MODULE_LIST[@]}; do
      sugar-module-uninstall "${module}" "${FORCE_UNINSTALL}"
      if [ ! ${?} -eq 0 ]; then
        _sugar-index-unlock "${LOCK}"
        return 1
      fi
    done
  fi

  if [ -n "${LOAD_MODULES}" ]; then
    sugar-modules-load ${MODULE_LIST[@]}
    if [ ! ${?} -eq 0 ]; then
      _sugar-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${RELOAD_SUGAR_SHELL}" ]; then
    sugar-reload
    if [ ! ${?} -eq 0 ]; then
      _sugar-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${AVAILABLE_SEARCH}" ]; then
    local MODULES=()

    if [ -n "${MODULE_LIST}" ]; then
      sugar-message "title" "Searching available modules..."
      for module in ${MODULE_LIST[@]}; do
        MODULES+=($(sugar-module-available-search "${module}"))
      done
    else
      sugar-message "title" "Available modules..."
      MODULES=($(cat "${SUGAR_INDEX_AVAILABLE}"))
    fi

    for module in ${MODULES[@]}; do
      sugar-message "bold" "${module}"
    done
  fi

  if [ -n "${INSTALLED_SEARCH}" ]; then
    local MODULES=()

    if [ -n "${MODULE_LIST}" ]; then
      sugar-message "title" "Searching installed modules..."
      for module in ${MODULE_LIST[@]}; do
        MODULES+=($(sugar-module-installed-search "${module}"))
      done
    else
      sugar-message "title" "Installed modules..."
      MODULES=($(cat "${SUGAR_INDEX_INSTALLED}"))
    fi

    for module in ${MODULES[@]}; do
      sugar-message "bold" "${module}"
    done
  fi

  _sugar-index-unlock "${LOCK}"
}
