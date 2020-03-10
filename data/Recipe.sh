
function recipe.parse(){
  local s
  local w
  local fs
  s='[[:blank:]]*'
  w='[a-zA-Z0-9_]*'
  fs="$(echo @|tr @ '\034')"
  sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
    -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$1" |
  awk -F"$fs" '{
  indent = length($1)/2;
  vname[indent] = $2;
  for (i in vname) {if (i > indent) {delete vname[i]}}
    if (length($3) > 0) {
      vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
      printf("%s%s%s=(\"%s\")\n", "'"SCRIPT_"'",vn, $2, $3);
    }
  }' | sed 's/_=/+=/g'
}

function recipe.download-file(){
  wget -q -c --show-progress --progress=bar:force:noscroll "${1}" || {
    echo "Error: Can't download file '${1}', wget exited with code ${?}"
    exit 1
  }
}

function recipe.extract(){
  unp ${1} || {
    echo "Error: Can't extract file '${1}', unp exited with code ${?}"
  }
}

function recipe.install-from-compressed(){
  FILE_PATH=$(readlink -f "${1}")
  TARGET_DIR="${BOTTLE_NAME}/prefix/drive_c"/$(echo "${2}" | cut -c 4- | sed 's/\\/\//g')
  CURRENT_DIR=$(pwd)
  
  mkdir -p "${TARGET_DIR}"
  cd "${TARGET_DIR}"
  
  unp -v "${FILE_PATH}" || {
    echo "Error: Can't extract file '${1}', unp exited with code ${?}"
  }
  cd "${CURRENT_DIR}"
}

function recipe.run(){
  echo "Parsing Recipe..."
  eval $(recipe.parse "${1}")
  
  DIST_RECIPE=$(basename "${1}" .yml)"_dist.yml"
  
  export BOTTLE_NAME="$(echo ${SCRIPT_app}  | sed 's/[[:space:]]//g')"
  
  [ "${BOTTLE_NAME}" = "" ] && {
    echo "Error: Missing 'app:' key"
    exit 1
  }
  [ "$(echo ${SCRIPT_executable}  | sed 's/[[:space:]]//g')" = "" ] && {
    echo "Error: Missing 'executable:' key"
    exit 1
  }
  [ "$(echo ${SCRIPT_category}  | sed 's/[[:space:]]//g')" = "" ] && {
    echo "Warning: Missing 'category:' key, your application will appear on 'Internet' section"
  }
  
  bottle.create-bottle
  
  for link in "${SCRIPT_ingredients_download[@]}"; do
    recipe.download-file ${link}
  done
  
  for package_to_install in "${SCRIPT_preparation_install_compressed[@]}"; do
    FILE=$(echo ${package_to_install} | cut -d' ' -f1)
    DIR=$(echo ${package_to_install} | sed "s|${FILE}||" )
    recipe.install-from-compressed "${FILE}" "${DIR}"
  done
  
  for package in "${SCRIPT_preparation_extract[@]}"; do
    recipe.extract "${package}"
  done
  
  for installer in "${SCRIPT_preparation_install[@]}"; do
    bottle.install "${installer}"
  done
  
  for file in "${SCRIPT_preparation_remove[@]}"; do
    bottle.remove-file "${file}"
  done
  
  bottle.set-name "${SCRIPT_app}"
  bottle.set-main-executable "${SCRIPT_executable}"
  
  [ ! "${SCRIPT_icon}" == "" ] && {
    bottle.set-icon "${SCRIPT_icon}"
  }
  
  [ ! "${SCRIPT_category}" == "" ] && {
    bottle.set-category "${SCRIPT_category}"
  }
  
  for flag in "${SCRIPT_flags[@]}"; do
    flags.enable ${flag}
  done
  
  appdir.create-appdir $(echo "${SCRIPT_keep_registry}" | grep -q ^"true"$ && echo "--keep-registry") --no-message
  
  [ -z ${SCRIPT_unused_files} ] && {
    cat "${1}" > "${DIST_RECIPE}"
    echo -e "\nunused_files:" >> "${DIST_RECIPE}"
    appdir.minimize --append-to-script "${DIST_RECIPE}"
  }
  
  [ ! -z ${SCRIPT_unused_files} ] && {
    echo "Removing unused files..."
    for file in "${SCRIPT_unused_files[@]}"; do
      rm "${BOTTLE_NAME}.AppDir/${file}"
    done
    find "${BOTTLE_NAME}.AppDir" -type l ! -exec test -e {} \; -delete
    find "${BOTTLE_NAME}.AppDir" -type d -empty -delete
  }
  
  appdir.package
}
