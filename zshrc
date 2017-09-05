#  Do not modify this file
#  If the available modules index file doesn't exist
#  index repositories and install active modules.
if [ ! -f "${SATAN_INDEX_AVAILABLE}" ]; then
  satan-repository-index
  satan-modules-active-install
fi

#  Load active modules
satan-modules-active-load
