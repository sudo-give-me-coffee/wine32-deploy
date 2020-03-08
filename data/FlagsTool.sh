
function flags.is-valid(){
  [ ! -f "${HERE}/Flags/${1}.flag" ] && {
    echo "The flag '${1}' isn't valid!"
    echo
    echo "Valid flags is:"
    ls "${HERE}/Flags/" | sed 's/^/  * /g' | sed 's/.flag$//g'
    echo
    exit 1
  }
}

function flags.list-flags(){
  echo "Currently supported flags:"
  for flag in "${HERE}/Flags"/*; do
     echo "  "$(basename "${flag}" .flag)
    echo "    -" $(cat "${flag}" | head -n1 | cut -c 3-)
  done
  exit 0
}

function flags.enable(){
  bottle.loadEnvironment
  flags.is-valid ${1}
  cp "${HERE}/Flags/${1}.flag" "${BOTTLE_NAME}"
  echo "Flag '$(echo ${1} | sed 's/.flag$//g')' was enabled"
}

function flags.disable(){
  bottle.loadEnvironment
  flags.is-valid ${1}
  rm  "${BOTTLE_NAME}/${1}.flag" &> /dev/null
  echo "Flag '$(echo ${1} | sed 's/.flag$//g')' was disabled"
}