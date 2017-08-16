#  Reload configuration
function reload() {
  environment-load
}

#  Load custom files
custom-load

#  Uninstall modules not in the modules arary
modules-uninstall -v

#  Install and load modules
modules-install -v
modules-load
