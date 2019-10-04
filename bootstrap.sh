#  If the available modules index file doesn't exist
#  index repositories and install enabled modules.
if [ ! -f "${SANTA_INDEX_AVAILABLE}" ]; then
  _santa-init
else
  if _santa-index-updates-check; then

    if [ "${SANTA_AUTO_UPDATE}" = "true" ]; then
      _santa-update
    fi

  fi
fi

#  Load enabled modules
DISPLAY_MODULE_LOAD="${SANTA_DISPLAY_MODULE_LOAD}" \
  santa-modules-enabled-load

#  Display ascii art
if [ "${SANTA_DISPLAY_ASCII_ART}" = "true" ]; then
  santa-ascii-skull
fi

#  Display ascii title
if [ "${SANTA_DISPLAY_ASCII_TITLE}" = "true" ]; then
  santa-credit
  santa-ascii-title
fi

santa-on-load

if [ -f "${HOME}/.zuser" ]; then
  source "${HOME}/.zuser"
fi
