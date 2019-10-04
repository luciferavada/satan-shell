#  Do not modify this file

#  Github URL
local GITHUB_URL="https://github.com"

#  Github API URL
local GITHUB_API_URL="https://api.github.com"

#  Sugar modules index lock uuid
local SANTA_INDEX_LOCK_UUID=""

#  Sugar modules index lock
local SANTA_INDEX_LOCK_FILE="${HOME}/.zsh.d/.index.lock"

#  Sugar modules available index
local SANTA_INDEX_AVAILABLE="${HOME}/.zsh.d/.index.available"

#  Sugar modules installed index
local SANTA_INDEX_INSTALLED="${HOME}/.zsh.d/.index.installed"

#  Sugar modules updates index
local SANTA_INDEX_UPDATES="${HOME}/.zsh.d/.index.updates"

#  Sugar modules updates index last checked since epoch time stamp
local SANTA_INDEX_UPDATES_CHECKED="${HOME}/.zsh.d/.index.updates.checked"

#  Sugar on load hook array
local SANTA_ON_LOAD=()

#  Sugar configuration files
local SANTA_DIRECTORIES_FILE="${HOME}/.zsh.d/directories.conf"
local SANTA_MODULES_FILE="${HOME}/.zsh.d/modules.conf"
local SANTA_REPOSITORIES_FILE="${HOME}/.zsh.d/repositories.conf"
local SANTA_SETTINGS_FILE="${HOME}/.zsh.d/settings.conf"

#  Load configuration variables
function santa-load-configuration-variables \
         santa-reload-configuration-variables() {
  source "${SANTA_DIRECTORIES_FILE}"
  source "${SANTA_MODULES_FILE}"
  source "${SANTA_REPOSITORIES_FILE}"
  source "${SANTA_SETTINGS_FILE}"
}

#  Display ascii skull
function santa-ascii-skull skull() {
  echo ""
  echo -n "$(tput ${COLOR[reset]}; tput bold; tput setaf ${COLOR[black]})"
  cat "${SANTA_INSTALL_DIRECTORY}/ascii-art/skull"
  echo -n "$(tput ${COLOR[reset]})"
  echo ""
}

#  Display ascii title
function santa-ascii-title() {
  echo -n "$(tput ${COLOR[reset]}; tput bold; tput setaf ${COLOR[red]})"
  cat "${SANTA_INSTALL_DIRECTORY}/ascii-art/title"
  echo -n "$(tput ${COLOR[reset]})"
  echo ""
}

#  Display credit
function santa-credit() {
  echo ""
  echo -n "$(tput ${COLOR[reset]}; tput bold; tput setaf ${COLOR[black]})"
  echo "   By: Lucifer Sears | Github: lucifersears | Twitter: @lucifersears"
  echo -n "$(tput ${COLOR[reset]})"
  echo ""
}

#  Display ascii demon
function santa-ascii-demon demon() {
  echo ""
  echo -n "$(tput ${COLOR[reset]}; tput setaf ${COLOR[magenta]})"
  cat "${SANTA_INSTALL_DIRECTORY}/ascii-art/demon"
  echo -n "$(tput ${COLOR[reset]})"
  echo ""
}

#  Display ascii header
function santa-ascii-header() {
  santa-ascii-skull
  santa-credit
  santa-ascii-title
}

#  Set trap for index lock file removal
function _santa-index-lock-trap() {
  trap "_santa-index-unlock \"${SANTA_INDEX_LOCK_UUID}\"; kill -INT $$" \
    SIGINT SIGHUP SIGQUIT SIGABRT SIGKILL SIGTERM
}

#  Reset trap index lock file removal
function _santa-index-lock-untrap() {
  trap - SIGINT SIGHUP SIGQUIT SIGABRT SIGKILL SIGTERM
}

#  Set trap for index lock await
function _santa-index-lock-await-trap() {
  trap "rm \"${SANTA_INDEX_LOCK_FILE}\"" SIGINT
}

#  Reset trap for index lock await
function _santa-index-lock-await-untrap() {
  trap - SIGINT
}

function _santa-index-lock-get-group() {
  local GROUP="${1}"
  cat "${SANTA_INDEX_LOCK_FILE}" | sed -E \
    "s/^([A-Fa-f0-9\-]+)\:([0-9]+)\:(.*)$/\\${GROUP}/"
}

#  Get the index lock file uuid
function _santa-index-lock-get-uuid() {
  _santa-index-lock-get-group "1"
}

#  Get the index lock file date
function _santa-index-lock-get-date() {
  _santa-index-lock-get-group "2"
}

#  Get the index lock file message
function _santa-index-lock-get-message() {
  _santa-index-lock-get-group "3"
}

#  Determine if the lock file has expired
function _santa-index-lock-check-date() {
  if [ -f "${SANTA_INDEX_LOCK_FILE}" ] && \
     [ -n "$(cat ${SANTA_INDEX_LOCK_FILE})" ]; then

    santa-reload-configuration-variables

    local -i CURRENT_TIME=$(date +%s)
    local -i LOCK_DATE=$(_santa-index-lock-get-date)
    local -i DIFFERENCE=$(( ${CURRENT_TIME} - ${LOCK_DATE} ))
    local -i REMAINING=$(( ${SANTA_INDEX_LOCK_FILE_EXPIRE} - ${DIFFERENCE} ))

    if [ ${REMAINING} -ne ${SANTA_INDEX_LOCK_FILE_EXPIRE} ]; then
      santa-message "info:reprint" "expires in: ${REMAINING}s"
    fi

    if [ ${DIFFERENCE} -ge ${SANTA_INDEX_LOCK_FILE_EXPIRE} ]; then
      santa-message "title" "Lock file expired..."
      rm "${SANTA_INDEX_LOCK_FILE}"
    fi
  fi
}

#  Determine if the lock uuid belongs to this shell instance
function _santa-index-lock-check-uuid() {
  if [ -f "${SANTA_INDEX_LOCK_FILE}" ]; then
    local LOCK_FILE_UUID=$(_santa-index-lock-get-uuid)
    if [ ! "${LOCK_FILE_UUID}" = "${SANTA_INDEX_LOCK_UUID}" ]; then
      return 1
    fi
  fi
  return 0
}

#  Wait for index lock
function _santa-index-lock-await() {
  local was_locked="false"

  if [ -f "${SANTA_INDEX_LOCK_FILE}" ]; then
    local -l LOCK_MESSAGE="$(_santa-index-lock-get-message)"
    santa-message "title" "Locked ${LOCK_MESSAGE}"
    santa-message "title" "Waiting for lock... (~/.zsh.d/.index.lock)"
    santa-message "title" "Force removal with: (CTRL+C)"
    _santa-index-lock-await-trap
  fi

  until [ ! -f "${SANTA_INDEX_LOCK_FILE}" ]; do
    was_locked="true"
    _santa-index-lock-check-date
    sleep "${SANTA_INDEX_LOCK_FILE_CHECK}"
  done

  if [ "${was_locked}" = "true" ]; then
    echo -n "\n"
  fi

  _santa-index-lock-await-untrap
}

#  Acquire the index lock
function _santa-index-lock() {
  if [ -z "${SANTA_INDEX_LOCK_UUID}" ]; then
    _santa-index-lock-await
    _santa-index-lock-trap

    local UUID=$(uuidgen)
    local -i CURRENT_TIME=$(date +%s)

    echo "${UUID}:${CURRENT_TIME}:${2}" > "${SANTA_INDEX_LOCK_FILE}"
    eval "SANTA_INDEX_LOCK_UUID=\"${UUID}\""
    eval "${1}=\"${SANTA_INDEX_LOCK_UUID}\""
  else
    eval "${1}=\"\""
  fi
}

#  Release the index lock
function _santa-index-unlock() {
  if ! _santa-index-lock-check-uuid; then
    santa-message "error" "lock removed..."
    _santa-index-lock-untrap
    kill -INT "$$"
    return 1
  fi

  local LOCK="${1}"

  if [ "${LOCK}" = "${SANTA_INDEX_LOCK_UUID}" ]; then
    _santa-index-lock-untrap
    eval "SANTA_INDEX_LOCK_UUID=\"\""
    rm "${SANTA_INDEX_LOCK_FILE}"
  fi
}

#  Add a module to the updates index file
function _santa-index-updates-write() {
  local MODULE_LINE="${1}"
  if [ -z $(grep "^${MODULE_LINE}$" "${SANTA_INDEX_UPDATES}") ]; then
    echo "${MODULE_LINE}" >> "${SANTA_INDEX_UPDATES}"
  fi
}

#  Write to the available modules index file
function _santa-index-available-write() {
  local REPOSITORY="${1}"
  grep "\"full_name\"" | sed "s/.*\"full_name\"\:\ \"\(.*\)\",/\1/" | \
    sort >> "${SANTA_INDEX_AVAILABLE}"
}

#  Add a module to the installed index file
function _santa-index-installed-write() {
  local MODULE_LINE="${1}"
  echo "${MODULE_LINE}" >> "${SANTA_INDEX_INSTALLED}"
}

#  Remove a module from the installed index file
function _santa-index-installed-remove() {
  local MODULE_LINE="${1}"
  local SANTA_INDEX_INSTALLED_TEMP=$(mktemp)
  cat "${SANTA_INDEX_INSTALLED}" | sed "/${MODULE_LINE//\//\\/}/d" > \
    "${SANTA_INDEX_INSTALLED_TEMP}"
  mv "${SANTA_INDEX_INSTALLED_TEMP}" "${SANTA_INDEX_INSTALLED}"
}

#  Remove a module from the updates index file
function _santa-index-updates-remove() {
  local MODULE_LINE="${1}"
  local SANTA_INDEX_UPDATES_TEMP=$(mktemp)
  cat "${SANTA_INDEX_UPDATES}" | sed "/${MODULE_LINE//\//\\/}/d" > \
    "${SANTA_INDEX_UPDATES_TEMP}"
  mv "${SANTA_INDEX_UPDATES_TEMP}" "${SANTA_INDEX_UPDATES}"
}

#  Determine if updates should be checked for
function _santa-index-updates-check() {
  local -i CURRENT_TIME="$(date +%s)"

  if [ ! -f "${SANTA_INDEX_UPDATES_CHECKED}" ] || \
     [ -z "$(cat ${SANTA_INDEX_UPDATES_CHECKED})" ]; then
    echo "${CURRENT_TIME}" > "${SANTA_INDEX_UPDATES_CHECKED}"
    return 0
  fi

  local -i LAST_CHECKED="$(cat ${SANTA_INDEX_UPDATES_CHECKED})"
  local -i DIFFERENCE=$(( ${CURRENT_TIME} - ${LAST_CHECKED} ))

  if [ ${DIFFERENCE} -gt ${SANTA_AUTO_UPDATE_CHECK} ]; then
    echo "${CURRENT_TIME}" > "${SANTA_INDEX_UPDATES_CHECKED}"
    return 0
  fi

  return 1
}

#  Display colorized message
function santa-message() {
  local TYPE="${1}"
  local MESSAGE="${2}"

  local SPLIT=(`echo ${TYPE//:/ }`)

  local TYPE="${SPLIT[1]}"
  local OPTION="${SPLIT[2]}"

  if [ -n "${OPTION}" ]; then
    case "${OPTION}" in
      "reprint") echo -n "\e[2K\r" ;;
      *)
        santa-message "error" "invalid message option: ${OPTION}"
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
      santa-message "error" "invalid message type: ${TYPE}"
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
function santa-template() {
  local TEMPLATE_SOURCE="${1}"
  local TEMPLATE_DESTINATION="${2}"

  if [ ! -f "${TEMPLATE_SOURCE}" ]; then
    santa-message "error" "missing template: ${TEMPLATE_SOURCE}"
    return 1
  fi

  eval "echo \"$(< ${TEMPLATE_SOURCE} )\"" > "${TEMPLATE_DESTINATION}"
}

#  Find an available module
function santa-module-available-find() {
  local LOCK
  _santa-index-lock "LOCK" "Finding an available module..."

  local MODULE="${1}"

  if [ -z "${MODULE}" ]; then
    _santa-index-unlock "${LOCK}"
    return 0
  fi

  if [ -f "${SANTA_INDEX_AVAILABLE}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SANTA_INDEX_AVAILABLE}" | grep --max-count "1" --regexp "/${1}$"
    else
      cat "${SANTA_INDEX_AVAILABLE}" | grep --max-count "1" --regexp "${1}$"
    fi
  fi

  _santa-index-unlock "${LOCK}"
}

#  Search available modules
function santa-module-available-search() {
  local LOCK
  _santa-index-lock "LOCK" "Searching available modules..."

  local MODULE="${1}"

  if [ -f "${SANTA_INDEX_AVAILABLE}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SANTA_INDEX_AVAILABLE}" | grep --regexp "/.*${1}.*"
    else
      cat "${SANTA_INDEX_AVAILABLE}" | grep --regexp ".*${1}.*"
    fi
  fi

  _santa-index-unlock "${LOCK}"
}

#  Find an installed module
function santa-module-installed-find() {
  local LOCK
  _santa-index-lock "LOCK" "Finding an installed module..."

  local MODULE="${1}"

  if [ -z "${MODULE}" ]; then
    _santa-index-unlock "${LOCK}"
    return 0
  fi

  if [ -f "${SANTA_INDEX_INSTALLED}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SANTA_INDEX_INSTALLED}" | grep --max-count "1" --regexp "/${1}$"
    else
      cat "${SANTA_INDEX_INSTALLED}" | grep --max-count "1" --regexp "${1}$"
    fi
  fi

  _santa-index-unlock "${LOCK}"
}

#  Search installed modules
function santa-module-installed-search() {
  local LOCK
  _santa-index-lock "LOCK" "Searching installed modules..."

  local MODULE="${1}"

  if [ -f "${SANTA_INDEX_INSTALLED}" ]; then
    local SPLIT=(`echo ${MODULE//\// }`)
    if [ ${#SPLIT[@]} -eq 1 ]; then
      cat "${SANTA_INDEX_INSTALLED}" | grep  --regexp "/.*${1}.*"
    else
      cat "${SANTA_INDEX_INSTALLED}" | grep  --regexp ".*${1}.*"
    fi
  fi

  _santa-index-unlock "${LOCK}"
}

#  Index available modules
function santa-repository-index() {
  local LOCK
  _santa-index-lock "LOCK" "Indexing repositories..."

  santa-message "title" "Indexing repositories..."

  santa-reload-configuration-variables

  rm -f "${SANTA_INDEX_AVAILABLE}"

  for repository in ${SANTA_REPOSITORIES[@]}; do

    santa-message "bold" "${repository}"

    local REPOSITORY_URL="${GITHUB_API_URL}/orgs/${repository}/repos"

    curl --silent --request "GET" "${REPOSITORY_URL}" | \
      _santa-index-available-write

    if [ ! ${?} -eq 0 ]; then
      _santa-index-unlock "${LOCK}"
      return 1
    fi

  done

  _santa-index-unlock "${LOCK}"
}

#  Install a module
function santa-module-install() {
  local LOCK
  _santa-index-lock "LOCK" "Installing a module..."

  local MODULE="${1}"
  local MODULE_LINE=$(santa-module-available-find "${MODULE}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPOSITORY="${MODULE_INFO[1]}"

  santa-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    santa-message "bold" "${MODULE}"
    santa-message "error" "not found."
    _santa-index-unlock "${LOCK}"
    return 0
  fi

  santa-message "bold" "${MODULE_LINE}"

  if [ -n "$(santa-module-installed-find ${MODULE_LINE})" ]; then
    santa-message "error" "module already installed."
    _santa-index-unlock "${LOCK}"
    return 0
  fi

  git clone "${GITHUB_URL}/${MODULE_REPOSITORY}/${MODULE_NAME}.git" \
    "${SANTA_MODULES_DIRECTORY}/${MODULE_REPOSITORY}/${MODULE_NAME}"

  if [ ${?} -eq 0 ]; then
    _santa-index-installed-write "${MODULE_LINE}"
  else
    santa-message "error" "failure."
    _santa-index-unlock "${LOCK}"
    return 1
  fi

  _santa-index-unlock "${LOCK}"
}

#  Uninstall a module
function santa-module-uninstall() {
  local LOCK
  _santa-index-lock "LOCK" "Uninstalling a module..."

  local MODULE="${1}"
  local MODULE_FORCE_UNINSTALL="${2}"
  local MODULE_LINE=$(santa-module-installed-find "${MODULE}")
  local MODULE_DIRECTORY="${SANTA_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_UNINSTALL="yes"

  santa-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    santa-message "bold" "${MODULE}"
    santa-message "error" "not found."
    _santa-index-unlock "${LOCK}"
    return 0
  fi

  santa-message "bold" "${MODULE_LINE}"

  git -C "${MODULE_DIRECTORY}" diff --exit-code --no-patch

  if [ -z "${MODULE_FORCE_UNINSTALL}" ] && [ ! ${?} -eq 0 ]; then

    santa-message "error" "${MODULE_LINE} has modifications."

    echo -n "Do you want to uninstall anyway? (yes/no) "
    read MODULE_UNINSTALL

    until [ "${MODULE_UNINSTALL}" = "yes" ] || \
          [ "${MODULE_UNINSTALL}" = "no" ]; do
      echo "Do you want to uninstall anyway? (yes/no)"
      echo -n "Enter yes or no... "
      read MODULE_UNINSTALL
    done

    if [ "${MODULE_UNINSTALL}" = "yes" ]; then
      santa-message "info" "uninstalling..."
    else
      santa-message "info" "not uninstalling..."
    fi

  fi

  if [ "${MODULE_UNINSTALL}" = "yes" ]; then

    rm -rf "${MODULE_DIRECTORY}"

    if [ ${?} -eq 0 ]; then
      _santa-index-installed-remove "${MODULE_LINE}"
    else
      santa-message "error" "failure."
      _santa-index-unlock "${LOCK}"
      return 1
    fi

  fi

  _santa-index-unlock "${LOCK}"
}

#  Check a module for updates
function santa-module-update-check() {
  local LOCK
  _santa-index-lock "LOCK" "Checking a module for updates..."

  local MODULE="${1}"
  local MODULE_LINE=$(santa-module-installed-find "${MODULE}")
  local MODULE_DIRECTORY="${SANTA_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_AVAILABLE=$(santa-module-available-find "${MODULE_LINE}")

  santa-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    santa-message "bold" "${MODULE}"
    santa-message "error" "not installed."
    _santa-index-unlock "${LOCK}"
    return 0
  fi

  if [ -z "${MODULE_AVAILABLE}" ]; then
    santa-message "bold" "${MODULE}"
    santa-message "error" "not in remote repository."
    _santa-index-unlock "${LOCK}"
    return 0
  fi

  git -C "${MODULE_DIRECTORY}" fetch origin

  if [ ! ${?} -eq 0 ]; then
    santa-message "error" "failure."
    _santa-index-unlock "${LOCK}"
    return 1
  fi

  # exits non-zero if there are updates available
  git -C "${MODULE_DIRECTORY}" diff --exit-code --no-patch master origin/master

  if [ ! ${?} -eq 0 ]; then
    santa-message "bold" "${MODULE}"
    santa-message "info" "updates available."
    _santa-index-updates-write "${MODULE_LINE}"
  fi

  _santa-index-unlock "${LOCK}"
}

#  Update a module
function santa-module-update() {
  local LOCK
  _santa-index-lock "LOCK" "Updating a module..."

  local MODULE="${1}"
  local MODULE_LINE=$(santa-module-installed-find "${MODULE}")
  local MODULE_DIRECTORY="${SANTA_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_AVAILABLE=$(santa-module-available-find "${MODULE_LINE}")

  santa-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    santa-message "bold" "${MODULE}"
    santa-message "error" "not installed."
    _santa-index-unlock "${LOCK}"
    return 0
  fi

  if [ -z "${MODULE_AVAILABLE}" ]; then
    santa-message "bold" "${MODULE}"
    santa-message "error" "not in remote repository."
    _santa-index-unlock "${LOCK}"
    return 0
  fi

  santa-message "bold" "${MODULE_LINE}"

  git -C "${MODULE_DIRECTORY}" pull

  if [ ${?} -eq 0 ]; then
    _santa-index-updates-remove "${MODULE_LINE}"
  else
    santa-message "error" "failure."
    _santa-index-unlock "${LOCK}"
    return 1
  fi

  _santa-index-unlock "${LOCK}"
}

#  Load a module
function santa-module-load() {
  local LOCK
  _santa-index-lock "LOCK" "Loading a module..."

  local MODULE="${1}"
  local MODULE_LINE=$(santa-module-installed-find "${MODULE}")
  local MODULE_INFO=(`echo ${MODULE_LINE//\// }`)
  local MODULE_NAME="${MODULE_INFO[2]}"
  local MODULE_REPOSITORY="${MODULE_INFO[1]}"
  local MODULE_DIRECTORY="${SANTA_MODULES_DIRECTORY}/${MODULE_LINE}"
  local MODULE_FILES=(${MODULE_DIRECTORY}/*.sh)

  santa-reload-configuration-variables

  if [ -z "${MODULE_LINE}" ]; then
    santa-message "bold" "${MODULE}"
    santa-message "error" "not installed."
    _santa-index-unlock "${LOCK}"
    return 0
  fi

  # DISPLAY_MODULE_LOAD can be provided at calltime, i.e.
  # DISPLAY_MODULE_LOAD='false' santa-module-load 'some/module'
  # DISPLAY_MODULE_LOAD='false' santa-modules-enabled-load
  if [ ! "${DISPLAY_MODULE_LOAD}" = "false" ]; then
    santa-message "bold" "${MODULE_LINE}"
  fi

  for file in ${MODULE_FILES[@]}; do
    MODULE_REPOSITORY="${MODULE_REPOSITORY}" \
      MODULE_NAME="${MODULE_NAME}" \
      MODULE_DIRECTORY="${MODULE_DIRECTORY}" \
      source "${file}"
  done

  _santa-index-unlock "${LOCK}"
}

#  Find a list of available modules
function santa-modules-available-find() {
  local LOCK
  _santa-index-lock "LOCK" "Finding available modules..."

  santa-message "title" "Finding available modules..."

  for module in ${@}; do

    santa-module-available-find "${module}"

    if [ ! ${?} -eq 0 ]; then
      _santa-index-unlock "${LOCK}"
      return 1
    fi

  done

  _santa-index-unlock "${LOCK}"
}

#  Search a list of available modules
function santa-modules-available-search() {
  local LOCK
  _santa-index-lock "LOCK" "Searching available modules..."

  santa-message "title" "Searching available modules..."

  for module in ${@}; do

    santa-module-available-search "${module}"

    if [ ! ${?} -eq 0 ]; then
      _santa-index-unlock "${LOCK}"
      return 1
    fi

  done

  _santa-index-unlock "${LOCK}"
}

#  Find a list of installed modules
function santa-modules-installed-find() {
  local LOCK
  _santa-index-lock "LOCK" "Finding installed modules..."

  santa-message "title" "Finding installed modules..."

  for module in ${@}; do

    santa-module-installed-find "${module}"

    if [ ! ${?} -eq 0 ]; then
      _santa-index-unlock "${LOCK}"
      return 1
    fi

  done

  _santa-index-unlock "${LOCK}"
}

#  Search a list of installed modules
function santa-modules-installed-search() {
  local LOCK
  _santa-index-lock "LOCK" "Searching installed modules..."

  santa-message "title" "Searching installed modules..."

  for module in ${@}; do

    santa-module-installed-search "${module}"

    if [ ! ${?} -eq 0 ]; then
      _santa-index-unlock "${LOCK}"
      return 1
    fi

  done

  _santa-index-unlock "${LOCK}"
}

#  Install a list of modules
function santa-modules-install() {
  local LOCK
  _santa-index-lock "LOCK" "Installing modules..."

  santa-message "title" "Installing modules..."

  for module in ${@}; do

    santa-module-install "${module}"

    if [ ! ${?} -eq 0 ]; then
      _santa-index-unlock "${LOCK}"
      return 1
    fi

  done

  _santa-index-unlock "${LOCK}"
}

#  Uninstall a list of modules
function santa-modules-uninstall() {
  local LOCK
  _santa-index-lock "LOCK" "Uninstalling modules..."

  santa-message "title" "Uninstalling modules..."

  for module in ${@}; do

    santa-module-uninstall "${module}"

    if [ ! ${?} -eq 0 ]; then
      _santa-index-unlock "${LOCK}"
      return 1
    fi

  done

  _santa-index-unlock "${LOCK}"
}

#  Check a list of modules for updates
function santa-modules-update-check() {
  local LOCK
  _santa-index-lock "LOCK" "Checking modules for updates..."

  santa-message "title" "Checking modules for updates..."

  for module in ${@}; do

    santa-message "info:reprint" "${module}"

    santa-module-update-check "${module}"

    if [ ! ${?} -eq 0 ]; then
      _santa-index-unlock "${LOCK}"
      return 1
    fi

  done

  santa-message "info:reprint" "done"

  echo -n "\n"

  _santa-index-unlock "${LOCK}"
}

#  Update a list of modules
function santa-modules-update() {
  local LOCK
  _santa-index-lock "LOCK" "Updating modules..."

  santa-message "title" "Updating modules..."

  for module in ${@}; do

    santa-message "title" "${module}"

    santa-module-update "${module}"

    if [ ! ${?} -eq 0 ]; then
      _santa-index-unlock "${LOCK}"
      return 1
    fi

  done

  echo -n "\n"

  _santa-index-unlock "${LOCK}"
}

#  Load a list of modules
function santa-modules-load() {
  local LOCK
  _santa-index-lock "LOCK" "Loading modules..."

  santa-reload-configuration-variables

  if [ "${SANTA_DISPLAY_MODULE_LOAD}" = "true" ]; then
    santa-message "title" "Loading modules..."
  fi

  for module in ${@}; do

    santa-module-load "${module}"

    if [ ! ${?} -eq 0 ]; then
      _santa-index-unlock "${LOCK}"
      return 1
    fi

  done

  _santa-index-unlock "${LOCK}"
}

#  Install enabled modules
function santa-modules-enabled-install() {
  santa-modules-install ${SANTA_MODULES[@]}
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Check enabled modules for updates
function santa-modules-enabled-update-check() {
  santa-modules-update-check ${SANTA_MODULES[@]}
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Update enabled modules
function santa-modules-enabled-update() {
  santa-modules-update ${SANTA_MODULES[@]}
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Load enabled modules
function santa-modules-enabled-load() {
  santa-modules-load ${SANTA_MODULES[@]}
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Check all installed modules for updates
function santa-modules-installed-update-check() {
  santa-modules-update-check $(cat "${SANTA_INDEX_INSTALLED}")
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Update all installed modules
function santa-modules-installed-update() {
  santa-modules-update $(cat "${SANTA_INDEX_INSTALLED}")
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

#  Load all installed modules
function santa-modules-installed-load() {
  santa-modules-load $(cat "${SANTA_INDEX_INSTALLED}")
  if [ ! ${?} -eq 0 ]; then
    return 1
  fi
}

function _santa-init() {
  local LOCK
  _santa-index-lock "LOCK" "Initializing santa-shell..."

  santa-message "title" "Initializing santa-shell..."

  santa-repository-index

  if [ ! ${?} -eq 0 ]; then
    _santa-index-unlock "${LOCK}"
    return 1
  fi

  santa-modules-enabled-install

  # initially create the ${SANTA_INDEX_UPDATES_CHECKED} file
  _santa-index-updates-check

  if [ ! ${?} -eq 0 ]; then
    _santa-index-unlock "${LOCK}"
    return 1
  fi

  _santa-index-unlock "${LOCK}"
}

#  Update santa-shell and enabled modules
function _santa-update() {
  local LOCK
  _santa-index-lock "LOCK" "Updating santa-shell..."

  santa-message "title" "Updating santa-shell..."

  santa-reload-configuration-variables

  git -C "${SANTA_INSTALL_DIRECTORY}" pull

  if [ ! ${?} -eq 0 ]; then
    _santa-index-unlock "${LOCK}"
    return 1
  fi

  santa-repository-index

  if [ ! ${?} -eq 0 ]; then
    _santa-index-unlock "${LOCK}"
    return 1
  fi

  santa-modules-enabled-update-check

  if [ ! ${?} -eq 0 ]; then
    _santa-index-unlock "${LOCK}"
    return 1
  fi

  if [ -f "${SANTA_INDEX_UPDATES}" ]; then
    santa-modules-update "$(cat ${SANTA_INDEX_UPDATES})"
    if [ ! ${?} -eq 0 ]; then
      _santa-index-unlock "${LOCK}"
      return 1
    fi
  fi

  _santa-index-unlock "${LOCK}"
}

#  Source santa-shell environment files
function santa-reload reload() {
  santa-message "title" "Reloading santa-shell..."
  exec -l zsh
}

function santa-update update() {
  _santa-update
  santa-reload
}

#  Add a command with parameters to the santa-on-load hook array
function @santa-load() {
  local STRING="'"
  local i
  for (( i = 1; i <= ${#}; i++ )); do
    STRING+="\"${@[${i}]}\""
    if [ ${i} -lt ${#} ]; then
      STRING+=" "
    fi
  done
  STRING+="'"
  if [[ ! "${SANTA_ON_LOAD}" =~ "${STRING}" ]]; then
    SANTA_ON_LOAD+=("${STRING}")
  fi
}

#  Run santa on load functions
function santa-on-load() {
  for string in ${SANTA_ON_LOAD[@]}; do
    local COMMAND=(${string//\'/})
    eval "${COMMAND[@]}"
  done
}

#  Santa module manager
function santa() {
  local LOCK
  _santa-index-lock "LOCK" "By santa command..."

  local INSTALL_MODULES=""
  local UNINSTALL_MODULES=""
  local UPDATE_MODULES=""
  local LOAD_MODULES=""
  local AVALIABLE_SEARCH=""
  local INSTALLED_SEARCH=""
  local GENERATE_INDEX=""
  local ENABLED_MODULES=""
  local INSTALLED_MODULES=""
  local RELOAD_SANTA_SHELL=""
  local FORCE_UNINSTALL=""
  local DISPLAY_HELP=""

  local MODULE_LIST=()

  if [[ -z "${@}" ]]; then
    _santa-index-unlock "${LOCK}"
    santa-man
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
      "r") RELOAD_SANTA_SHELL="true" ;;
      "h") DISPLAY_HELP="true" ;;
      *) DISPLAY_HELP="true" ;;
    esac
  done

  if [ -n "${DISPLAY_HELP}" ]; then
    _santa-index-unlock "${LOCK}"
    santa-man
    return 0
  fi

  santa-reload-configuration-variables

  MODULE_LIST=(${@:${OPTIND}})

  if [ -n "${INSTALLED_MODULES}" ]; then
    MODULE_LIST=($(cat "${SANTA_INDEX_INSTALLED}"))
  fi

  if [ -n "${ENABLED_MODULES}" ]; then
    MODULE_LIST=(${SANTA_MODULES[@]})
  fi

  if [ -n "${GENERATE_INDEX}" ]; then
    santa-repository-index
    if [ ! ${?} -eq 0 ]; then
      _santa-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${INSTALL_MODULES}" ]; then
    santa-modules-install ${MODULE_LIST[@]}
    if [ ! ${?} -eq 0 ]; then
      _santa-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${UPDATE_MODULES}" ]; then
    santa-modules-enabled-update-check
    if [ -f "${SANTA_INDEX_UPDATES}" ]; then
      santa-modules-update $(cat ${SANTA_INDEX_UPDATES})
      if [ ! ${?} -eq 0 ]; then
        _santa-index-unlock "${LOCK}"
        return 1
      fi
    fi
  fi

  if [ -n "${UNINSTALL_MODULES}" ]; then
    santa-message "title" "Uninstalling modules..."
    for module in ${MODULE_LIST[@]}; do
      santa-module-uninstall "${module}" "${FORCE_UNINSTALL}"
      if [ ! ${?} -eq 0 ]; then
        _santa-index-unlock "${LOCK}"
        return 1
      fi
    done
  fi

  if [ -n "${LOAD_MODULES}" ]; then
    santa-modules-load ${MODULE_LIST[@]}
    if [ ! ${?} -eq 0 ]; then
      _santa-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${RELOAD_SANTA_SHELL}" ]; then
    santa-reload
    if [ ! ${?} -eq 0 ]; then
      _santa-index-unlock "${LOCK}"
      return 1
    fi
  fi

  if [ -n "${AVAILABLE_SEARCH}" ]; then
    local MODULES=()

    if [ -n "${MODULE_LIST}" ]; then
      santa-message "title" "Searching available modules..."
      for module in ${MODULE_LIST[@]}; do
        MODULES+=($(santa-module-available-search "${module}"))
      done
    else
      santa-message "title" "Available modules..."
      MODULES=($(cat "${SANTA_INDEX_AVAILABLE}"))
    fi

    for module in ${MODULES[@]}; do
      santa-message "bold" "${module}"
    done
  fi

  if [ -n "${INSTALLED_SEARCH}" ]; then
    local MODULES=()

    if [ -n "${MODULE_LIST}" ]; then
      santa-message "title" "Searching installed modules..."
      for module in ${MODULE_LIST[@]}; do
        MODULES+=($(santa-module-installed-search "${module}"))
      done
    else
      santa-message "title" "Installed modules..."
      MODULES=($(cat "${SANTA_INDEX_INSTALLED}"))
    fi

    for module in ${MODULES[@]}; do
      santa-message "bold" "${module}"
    done
  fi

  _santa-index-unlock "${LOCK}"
}

#  Load configuration variables
santa-load-configuration-variables

#  Bootstrap the environment
source "${SANTA_INSTALL_DIRECTORY}/bootstrap.sh"
