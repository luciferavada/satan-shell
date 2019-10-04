#  If the available modules index file doesn't exist
#  index repositories and install enabled modules.
if [ ! -f "${CANDY_INDEX_AVAILABLE}" ]; then
  _candy-init
else
  if _candy-index-updates-check; then

    if [ "${CANDY_AUTO_UPDATE}" = "true" ]; then
      _candy-update
    fi

  fi
fi

#  Load enabled modules
DISPLAY_MODULE_LOAD="${CANDY_DISPLAY_MODULE_LOAD}" \
  candy-modules-enabled-load

#  Display ascii title
if [ "${CANDY_DISPLAY_ASCII_TITLE}" = "true" ]; then
  candy-ascii-title
fi

candy-on-load

if [ -f "${HOME}/.zuser" ]; then
  source "${HOME}/.zuser"
fi
