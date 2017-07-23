## RedTube
#  `torcurl()` is defined in zprofile.

#  Variables
local REDTUBE="https://www.redtube.com"
local REDTUBE_LOGIN="${REDTUBE}/htmllogin"
local COOKIE="${TMPDIR}/redtube.cookie"
local STATUS="Status: %{http_code}\n"
local DIRECTORY="/Volumes/Flash/.Private"

#  Display RedTube cookie contents
function redcookie() {
  cat "${COOKIE}"
}

#  Initiate a RedTube session
function redsession() {
  # Create a RedTube session and cookie
  torcurl --silent --request "GET" "${REDTUBE_LOGIN}" \
    --write-out "${STATUS}" \
    --cookie-jar "${COOKIE}" \
    --output "/dev/null"

  # Strip comments and blank lines from the RedTube cookie
  cat "${COOKIE}" | sed "/^#/d" | sed "/^$/d" | tee "${COOKIE}"
}

#  Login to RedTube
function redlogin() {
  printf "Username: "; read USERNAME
  printf "Password: "; read -s PASSWORD
  printf "\n"

  torcurl --silent --request "POST" "${REDTUBE_LOGIN}" \
    --form "sUsername=${USERNAME}" --form "sPassword=${PASSWORD}" \
    --form "do=login" --form "iFriendID=0" \
    --form "bRemeber=2" --form "iObjectType=1" \
    --form "iObjectID=0" \
    --write-out "${STATUS}" \
    --cookie "${COOKIE}" \
    --cookie-jar "${COOKIE}" \
    --output "/dev/null"
}

#  Get a RedTube page
function redpage() {
  torcurl --silent --request "GET" "${1}" "${@:2}" \
      --cookie "${COOKIE}"
}

#  Get RedTube download links from a redpage() response
function redlink() {
  grep -E "download-link-(480|720)p"
}

#  Select RedTube download link from a redlink() response
function redselect() {
  INPUT=$(cat -)
  HIRES=$(echo "${INPUT}" | grep -E "download-link-720p")
  LORES=$(echo "${INPUT}" | grep -E "download-link-480p")
  echo "${HIRES:-$LORES}"
}

#  Extract href value from a redselect() response
function redhref() {
  grep -oE "https://[^\"]*"
}

#  Download a video from RedTube
function redcurl() {
  local FILE=$(echo "${1}" | grep -oE "[0-9]+\.mp4")
  local OUTPUT="${DIRECTORY}/${FILE}"

  torcurl --request "GET" "${1}" --output "${OUTPUT}" --continue-at - \
    --write-out "${STATUS}" \
    --cookie "${COOKIE}" \
    --cookie-jar "${COOKIE}"
}

#  Download a RedTube video from a RedTube video ID
function redget() {
  redcurl $(redpage "${REDTUBE}/${1}" | redlink | redselect | redhref)
}

#  Download a RedTube video from a RedTube video URL
function redurl() {
  redcurl $(redpage "${1}" | redlink | redselect | redhref)
}
