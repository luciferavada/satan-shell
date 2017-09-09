#  Do not modify this file

#  Load configuration variables
satan-load-configuration-variables

#  If the available modules index file doesn't exist
#  index repositories and install enabled modules.
if [ ! -f "${SATAN_INDEX_AVAILABLE}" ]; then
  satan-repository-index
  satan-modules-enabled-install
fi

if [ "${SATAN_AUTO_UPDATE}" = "true" ]; then

  if _satan-index-updates-check; then
    satan-message "Checking for updates..."
    satan-modules-enabled-update-check
  fi

  if [ -n "$(cat ${SATAN_INDEX_UPDATES})" ]; then
    satan-message "title" "Updating modules..."
    satan-modules-update $(cat "${SATAN_INDEX_UPDATES}")
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

if [ -n "$(cat ${SATAN_INDEX_UPDATES})" ]; then
  satan-message "title" "Module updates available."
fi
