## Python
#  Python 2.7 path
local PYTHON_PATH="${HOME}/Library/Python/2.7"

#  Add Python executables to $PATH
export PATH="${PATH}:${PYTHON_PATH}/bin"

#  Remove all packages from a Python environment
function pip-clean() {
  pip freeze | xargs pip uninstall -y
}


## Python Virtual Environment
#  Virtual environment folder
local VENV_FOLDER="venv"

#  Virtual environment activation file
local VENV_ACTIVATE=".venv-activate"

#  Virtual environment deactivation file
local VENV_DEACTIVATE=".venv-deactivate"

#  Requirements Filename
local REQUIREMENTS_FILE=".requirements"

#  Initialize a Python virtual environment
function venv-init() {
  local PYTHON="${1:-python2.7}"
  local PYTHON_PATH=$(which ${PYTHON})

  if [ ! -d "${VENV_FOLDER}" ]; then
    virtualenv --python "${PYTHON_PATH}" "${VENV_FOLDER}"
  fi

  if [ ! -f "${VENV_ACTIVATE}" ]; then
    echo "export MODULE=\"\"" > "${VENV_ACTIVATE}"
  fi

  if [ ! -f "${VENV_DEACTIVATE}" ]; then
    echo "unset MODULE" > "${VENV_DEACTIVATE}"
  fi

  # activate the newly created python virtual environment
  venv-activate
}

#  Activate a python virtual environment
function venv-activate() {
  if [ -n "${VIRTUAL_ENV}" ]; then
    venv-deactivate
  fi
  source "${PWD}/${VENV_FOLDER}/bin/activate"
  source "${PWD}/${VENV_ACTIVATE}"
}

#  Deactivate a python virtual environment
function venv-deactivate() {
  source "$(dirname ${VIRTUAL_ENV})/${VENV_DEACTIVATE}"
  deactivate
}

#  Install packages in a virtual environment
function venv-install() {
  pip install -r "${REQUIREMENTS_FILE}"
}

#  Create a requirements file for the virtual environment
function venv-update() {
  if [ -f "${REQUIREMENTS_FILE}" ]; then
    mv "${REQUIREMENTS_FILE}" "${REQUIREMENTS_FILE}.back"
  fi
  pip freeze > "${REQUIREMENTS_FILE}"
}

#  Remove packages from the virtual environment
function venv-clean() {
  if [ -f "${VENV_ACTIVATE}" ]; then
    venv-activate
    pip-clean
    venv-update
  else
    echo "Not in a python virtual environment folder."
  fi
}

#  Virtual environment names
function venv-name() {
  if [ -n "${VIRTUAL_ENV}" ]; then
    basename $(dirname "${VIRTUAL_ENV}")
  fi
}

function venv-python-test() {
  if [ $(which -s coverage) ]; then
    coverage run --source "${MODULE}" \
      --module "unittest" "test"
    coverage report
  else
    python -m "unittest" "test"
  fi
}

function venv-tornado-test() {
  if [ $(which -s coverage) ]; then
    coverage run --source "${MODULE}" \
      --module "tornado.testing" "test"
    coverage report
  else
    python -m "tornado.testing" "test"
  fi
}
