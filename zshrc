#  Do not modify this file

#  Load configuration variables
sugar-load-configuration-variables

#  If the available modules index file doesn't exist
#  index repositories and install enabled modules.
if [ ! -f "${SUGAR_INDEX_AVAILABLE}" ]; then
  _sugar-init
else
  if _sugar-index-updates-check; then

    if [ "${SUGAR_AUTO_UPDATE}" = "true" ]; then
      _sugar-update
    fi

  fi
fi

#  Load enabled modules
sugar-modules-enabled-load

#  Display ascii art
if [ "${SUGAR_DISPLAY_ASCII_ART}" = "true" ]; then
  sugar-ascii-art
fi

#  Display ascii title
if [ "${SUGAR_DISPLAY_ASCII_TITLE}" = "true" ]; then
  sugar-credit
  sugar-ascii-title
fi

sugar-on-load
