#!/usr/bin/env zsh

#  Source utility file
source "${PWD}/util/util.sh"

#  Skip the following files and directories when installing
local SKIP=(
  "install.sh" "install-github.sh" "README.md" "util" "zlogin.example"
)

#  Split paths on `/` and store in an array
local HOME_PATH=(`echo ${HOME//\// }`)
local BASE_PATH=(`echo ${PWD//\// }`)

#  Remove ${HOME_PATH} from ${BASE_PATH} to create ${BASE}
for i in ${HOME_PATH}; do
  # remove any element which contains $i
  local BASE_PATH=(${BASE_PATH[@]//*$i*})
done

#  Join ${BASE_PATH} with `/` and store as a string
local BASE="${BASE_PATH// //}"

#  Create an array from files in the current directory
local FILES=(*)

#  Link files
if [ -n "${FILES}" ]; then
  for file in ${FILES[@]}; do

    if [ $(contains "${file}" "${SKIP[@]}") ]; then
      continue
    fi

    local SRC="${BASE}/${file}"
    local DST="${HOME}/.${file}"

    echo "linking: ${SRC} -> ${DST}"
    #ln -sfh "${SRC}" "${DST}"

  done
fi

#  Modules file
local ZSHELL_MODULES_FILE="${HOME}/.zsh.d/modules.conf"

#  Write default modules file
if [ ! -f "${ZSHELL_MODULES_FILE}" ]; then
  echo "#  Modules are loaded in order" > "${ZSHELL_MODULES_FILE}"
  echo "MODULES=(" >> "${ZSHELL_MODULES_FILE}"
  echo "  \"prompt\" \"history\" \"ls\" \"man\" \"ssh\" \"git\"" >> \
    "${ZSHELL_MODULES_FILE}"
  echo ")" >> "${ZSHELL_MODULES_FILE}"
  echo "\n" >> "${ZSHELL_MODULES_FILE}"
fi

#  RC file
local ZSHELL_RC_FILE="${HOME}/.zsh.d/rc.conf"

#  Write default rc file
if [ ! -f "${ZSHELL_RC_FILE}" ]; then
  echo "#  Install dircetory" > "${ZSHELL_RC_FILE}"
  echo "ZSHELL_INSTALL_DIRECTORY=\"${BASE}\"" >> "${ZSHELL_RC_FILE}"
  echo "\n" >> "${ZSHELL_RC_FILE}"

  echo "#  Configuration directory" >> "${ZSHELL_RC_FILE}"
  echo "ZSHELL_CONFIGURATION_DIRECTORY=\"${HOME}/.zsh.d.conf\"" >> \
    "${ZSHELL_RC_FILE}"
  echo "\n" >> "${ZSHELL_RC_FILE}"

  echo "#  Modules directory" >> "${ZSHELL_RC_FILE}"
  echo "ZSHELL_MODULES_DIRECTORY=\"${HOME}/.zsh.d.modules\"" >> \
    "${ZSHELL_RC_FILE}"
  echo "\n" >> "${ZSHELL_RC_FILE}"
fi

#  Create zlogin file
if [ ! -f "${HOME}/.zlogin" ]; then
  touch "${HOME}/.zlogin"
fi

#  Source environment-load function
source "${HOME}/.zprofile"

#  Load environment
environment-load
