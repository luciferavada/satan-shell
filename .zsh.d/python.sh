## Python Functions
#  AutoEnv file
local AUTOENV_ENV_FILENAME=".pythonrc"

#  AutoEnv path
local AUTOENV_PATH="$(brew --prefix autoenv)"

#  Source AutoEnv shell script
source "${AUTOENV_PATH}/activate.sh"

#  Initialize a Python virtual environment
function venv-init() {
  local VENV_FOLDER="venv"
  local PYTHON="${1:-python2.7}"
  local PYTHON_PATH=$(which ${PYTHON})

  if [ ! -d "${VENV_FOLDER}" ]; then
    virtualenv --python "${PYTHON_PATH}" "${VENV_FOLDER}"
  fi

  if [ ! -f "${AUTOENV_ENV_FILENAME}" ]; then
    echo "source \"\${PWD}/venv/bin/activate\"" > "${AUTOENV_ENV_FILENAME}"
  fi

  # activate the newly created python virtual environment
  cd "${PWD}"
  cat <<< "y" 2>&1 /dev/null
}

#  Activate a python virtual environment
function venv-activate() {
  # reads the .pythonrc file in the current directory
  cd .
}

#  Deactivate a python virtual environment
function venv-deactivate() {
  deactivate
}

#  Remove all packages from a Python environment
function pip-clean() {
  pip freeze | xargs pip uninstall -y
}
