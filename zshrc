#  Do not modify this file

#  Source ~/.zshenv if the ${COLOR} array is not defined
if [ -z "${COLOR}" ]; then
  source "${HOME}/.zshenv"
fi

#  Source ~/.zprofile if the `satan` command is undefined
if [ -z $(whence satan) ]; then
  source "${HOME}/.zprofile"
fi

#  Load configuration variables
satan-load-configuration-variables

#  If the available modules index file doesn't exist
#  index repositories and install enabled modules.
if [ ! -f "${SATAN_INDEX_AVAILABLE}" ]; then
  _satan-init
else
  if _satan-index-updates-check; then

    if [ "${SATAN_AUTO_UPDATE}" = "true" ]; then
      _satan-update
    fi

  fi
fi

#  Load enabled modules
DISPLAY_MODULE_LOAD="${SATAN_DISPLAY_MODULE_LOAD}" \
  satan-modules-enabled-load

#  Display ascii art
if [ "${SATAN_DISPLAY_ASCII_ART}" = "true" ]; then
  satan-ascii-skull
fi

#  Display ascii title
if [ "${SATAN_DISPLAY_ASCII_TITLE}" = "true" ]; then
  satan-credit
  satan-ascii-title
fi

satan-on-load

if [ -f "${HOME}/.zuser" ]; then
  source "${HOME}/.zuser"
fi
