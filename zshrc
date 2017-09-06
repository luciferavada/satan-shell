#  Do not modify this file

#  Load configuration variables
satan-load-configuration-variables

#  If the available modules index file doesn't exist
#  index repositories and install active modules.
if [ ! -f "${SATAN_INDEX_AVAILABLE}" ]; then
  satan-repository-index
  satan-modules-active-install
fi

#  Load active modules
satan-modules-active-load

#  Display ascii art
if [ "${SATAN_DISPLAY_ASCII_ART}" = "true" ]; then
  satan-ascii-art
fi

#  Display ascii title
if [ "${SATAN_DISPLAY_ASCII_TITLE}" = "true" ]; then
  satan-credit
  satan-ascii-title
fi
