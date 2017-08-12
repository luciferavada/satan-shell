## Python
#  Remove all packages from a Python environment
function pip-clean() {
  pip freeze | xargs pip uninstall -y
}


## Python AutoEnv
#  Requirements Filename
local REQUIREMENTS_FILE=".requirements"

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
  venv-activate
  # write 'y' to stdin to enter the virtual environment for the first time
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

# Create a requirements file for the virtual environment
function venv-update() {
  if [ -f "${REQUIREMENTS_FILE}" ]; then
    mv "${REQUIREMENTS_FILE}" "${REQUIREMENTS_FILE}.back"
  fi
  pip freeze > "${REQUIREMENTS_FILE}"
}

# Remove packages from the virtual environment
function venv-clean() {
  if [ -f "${AUTOENV_ENV_FILENAME}" ]; then
    venv-activate
    pip-clean
    venv-update
  else
    echo "Not in a python virtual environment folder."
  fi
}

# Virtual environment names
function venv-name() {
  if [ -n "${VIRTUAL_ENV}" ]; then
    basename $(dirname "${VIRTUAL_ENV}")
  fi
}
