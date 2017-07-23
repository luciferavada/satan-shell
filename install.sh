#!/usr/bin/env zsh

local HOME_PATH=(`echo ${HOME//\// }`)
local BASE_PATH=(`echo ${PWD//\// }`)

# remove ${HOME} from ${PWD} to create ${BASE}
for i in ${HOME_PATH}; do
  # remove any element which contains $i
  local BASE_PATH=(${BASE_PATH[@]//*$i*})
done

local BASE="${BASE_PATH// //}"
local SKIP=("install.sh" "README.md")
local FILES=(*)

if [ -n "${FILES}" ]; then
  for file in ${FILES}; do

    if [[ "${SKIP[@]}" =~ "${file}" ]]; then
      continue
    fi

    ln -sfh "${BASE}/${file}" "${HOME}/.${file}"
    echo "linking: ${BASE}/${file} -> ${HOME}/.${file}"

  done
fi
