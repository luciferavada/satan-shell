#  Do not modify this file

#  Load configuration variables
satan-load-configuration-variables

#  If the available modules index file doesn't exist
#  index repositories and install enabled modules.
if [ ! -f "${SATAN_INDEX_AVAILABLE}" ]; then
  local LOCK
  _satan-index-lock "LOCK"

  satan-repository-index
  satan-modules-enabled-install

  _satan-index-unlock "${LOCK}"
fi

if [ "${SATAN_AUTO_UPDATE}" = "true" ]; then

  if _satan-index-updates-check; then
    local LOCK
    _satan-index-lock "LOCK"

    satan-message "title" "Updating satan-shell..."
    git -C "${SATAN_INSTALL_DIRECTORY}" pull

    satan-modules-enabled-update-check
    satan-modules-update $(cat "${SATAN_INDEX_UPDATES}")

    _satan-index-unlock "${LOCK}"
  fi

fi

#  Load enabled modules
satan-modules-enabled-load

#  Display ascii art
if [ "${SATAN_DISPLAY_ASCII_ART}" = "true" ]; then
  satan-ascii-art
fi

#  Display ascii title
if [ "${SATAN_DISPLAY_ASCII_TITLE}" = "true" ]; then
  satan-credit
  satan-ascii-title
fi
