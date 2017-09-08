#  Do not modify this file

#  Load configuration variables
satan-load-configuration-variables

#  If the available modules index file doesn't exist
#  index repositories and install enabled modules.
if [ ! -f "${SATAN_INDEX_AVAILABLE}" ]; then
  satan-repository-index
  satan-modules-enabled-install
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

if _satan-index-updates-check; then
  (satan-modules-enabled-update-check 2>&1 > /dev/null &)
fi

if [ -n "$(cat ${SATAN_INDEX_UPDATES})" ]; then
  satan-message "title" "Module updates available."
fi
