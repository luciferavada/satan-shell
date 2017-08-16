#!/usr/bin/env zsh

#  Skip the following files when installing
local SKIP=("install.sh" "github.sh" "README.md")

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

if [ -n "${FILES}" ]; then
  for file in ${FILES}; do

    if [[ "${SKIP[@]}" =~ "${file}" ]]; then
      continue
    fi

    local SRC="${BASE}/${file}"
    local DST="${HOME}/.${file}"

    echo "linking: ${SRC} -> ${DST}"
    ln -sfh "${SRC}" "${DST}"

  done
fi
