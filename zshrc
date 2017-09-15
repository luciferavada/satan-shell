#  Do not modify this file

#  Load configuration variables
satan-load-configuration-variables

#  If the available modules index file doesn't exist
#  index repositories and install enabled modules.
if [ ! -f "${SATAN_INDEX_AVAILABLE}" ]; then
  local LOCK
  _satan-index-lock "LOCK" "Initializing satan-shell..."

  satan-message "title" "Initializing satan-shell..."

  satan-repository-index

  if [ ! ${?} -eq 0 ]; then
    _satan-index-unlock "${LOCK}"
    return 1
  fi

  satan-modules-enabled-install

  if [ ! ${?} -eq 0 ]; then
    _satan-index-unlock "${LOCK}"
    return 1
  fi

  _satan-index-unlock "${LOCK}"
else
  if [ "${SATAN_AUTO_UPDATE}" = "true" ]; then

    if _satan-index-updates-check; then
      local LOCK
      _satan-index-lock "LOCK" "Automatically updating satan-shell..."

      satan-message "title" "Automatically updating satan-shell..."

      git -C "${SATAN_INSTALL_DIRECTORY}" pull

      if [ ! ${?} -eq 0 ]; then
        _satan-index-unlock "${LOCK}"
        return 1
      fi

      satan-modules-enabled-update-check

      if [ ! ${?} -eq 0 ]; then
        _satan-index-unlock "${LOCK}"
        return 1
      fi

      if [ -f "${SATAN_INDEX_UPDATES}" ]; then
        satan-modules-update $(cat "${SATAN_INDEX_UPDATES}")
        if [ ! ${?} -eq 0 ]; then
          _satan-index-unlock "${LOCK}"
          return 1
        fi
      fi

      _satan-index-unlock "${LOCK}"
    fi

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

satan-on-load
