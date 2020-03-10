
function bottle.create-bottle(){
  export WINEARCH=win32
  export WINEPREFIX=$(readlink -m ${BOTTLE_NAME}/prefix)
  export HOME=$(readlink -m "${BOTTLE_NAME}")
  export XDG_CONFIG_HOME="${HOME}/config"
  
  echo "[ 1/6 ] Creating basic structure..."
  mkdir -p "${BOTTLE_NAME}/"{config,prefix/drive_c/windows}
  echo "[ 2/6 ] Creating prefix..."
  "${HERE}/wineserver"
  WINEDEBUG=-all "${HERE}"/wine regedit "${HERE}"/default.reg
  cp "${HERE}/wine.desktop" "${BOTTLE_NAME}/${BOTTLE_NAME}.desktop"
  cp "${HERE}/Wine.png" "${BOTTLE_NAME}/${BOTTLE_NAME}.png"
  sed -i "s|Name=Wine|Name=${BOTTLE_NAME}|g" "${BOTTLE_NAME}/${BOTTLE_NAME}.desktop"
  sed -i "s|Icon=Wine|Icon=${BOTTLE_NAME}|g" "${BOTTLE_NAME}/${BOTTLE_NAME}.desktop"
  
  echo "[ 3/5 ] Creating a backup of registry..."
  cp "${BOTTLE_NAME}/prefix/system.reg" "${BOTTLE_NAME}/system.reg.orig"
  
  echo "[ 4/6 ] Extracting fonts..."  
  for font in "${HERE}/Resources/Fonts"/*; do
    tar --extract --file "${font}" --directory="${BOTTLE_NAME}/prefix/drive_c/windows/Fonts/" --gzip 2> /dev/null
  done
  
  echo "[ 5/6 ] Copying KupoFL theme..."
  mkdir -p "${BOTTLE_NAME}/prefix/drive_c/windows/Resources/Themes/kupofl/"
  cp "${HERE}/Resources/MSStyle/kupofl.msstyles" "${BOTTLE_NAME}/prefix/drive_c/windows/Resources/Themes/kupofl/"
  
  echo "[ 6/6 ] All steps is done!"
}

function bottle.install(){
  bottle.loadEnvironment
  [ ! -f "${1}" ] && {
    echo "File '${1}' not found"
    exit 1
  }
  echo  
  echo Starting installer "${1}" in ${BOTTLE_NAME}...
  "${HERE}/wineserver"
  "${HERE}"/wine "${1}" "${2}" 2> /dev/null
  echo
}

function bottle.set-main-executable(){
  bottle.loadEnvironment
  bottle.fileExist ${1}
  echo -n ${*} > "${BOTTLE_NAME}"/executable && {
    echo "File ${1} has defined as main executable"
  }
  local EXECUTABLE_NAME=$(basename "$(echo ${1} | tr [A-Z] [a-z])" .exe)
  local ICON_NAME=$(ls ${BOTTLE_NAME}/.local/share/icons/hicolor/256x256/apps | grep -i "${EXECUTABLE_NAME}" | tail -n1)
  [ ! "${ICON_NAME}" = "" ] && {
    bottle.set-icon "${BOTTLE_NAME}/.local/share/icons/hicolor/256x256/apps/${ICON_NAME}"
  }
}

function bottle.remove-file(){
  bottle.loadEnvironment
  bottle.fileExist ${1}
  rm "${FILE_PATH}" && {
    echo "File '${1}' has been removed"
  }
}

function bottle.set-icon(){
  bottle.loadEnvironment
  [ ! -f "${1}" ] && {
    echo "File '${1}' not found"
    exit 1
  }

  [ ! "$(file ${1} | cut -d' ' -f2)" == "PNG" ] && {
    echo "Warning: ${1} does not appear to be a valid PNG image"
  }
  
  cp "${1}" "${BOTTLE_NAME}"/"${BOTTLE_NAME}.png"
  echo "The application icon was changed to '$(basename ${1})'"
}

function bottle.set-name(){
  bottle.loadEnvironment
  [ "$(echo ${1} | sed 's/[[:space:]]//g')" == "" ] && {
    echo "Error: the application name cannot be empty or contain only spaces"
    exit 1
  }
  sed -i '/^Name=/d' "${BOTTLE_NAME}/${BOTTLE_NAME}.desktop"
  echo "Name=${1}" >> "${BOTTLE_NAME}/${BOTTLE_NAME}.desktop"
  echo "The application name has defined to '${1}'"
}

function bottle.set-category(){
  bottle.loadEnvironment
  [ "$(echo ${1} | sed 's/[[:space:]]//g')" == "" ] && {
    echo "Error: the application category cannot be empty or contain spaces"
    help.categories
  }
  
  VALID_CATEGORIES=(AudioVideo Audio Video  Development Education
                    Graphics   Game  Office Network     Science
                    Settings System Utility)
                    
  CATEGORY=$(echo " ${VALID_CATEGORIES[*]} " | grep -o " ${1} " | sed 's/ //g')
  if [ "${CATEGORY}" == "" ]; then
    echo "Error: You must provide a valid category!"
    help.categories
  fi
                    
  sed -i '/^Categories=/d' "${BOTTLE_NAME}/${BOTTLE_NAME}.desktop"
  echo "Categories=${1};" >> "${BOTTLE_NAME}/${BOTTLE_NAME}.desktop"
  echo "The application category has defined to '${1}'"
}

function bottle.fileExist(){
  bottle.loadEnvironment
  export FILE_PATH="${BOTTLE_NAME}"/prefix/drive_c/$(echo ${*} | sed 's|\\|/|g' | cut -c 4-)
  [ "${1}" = "" ] && {
    echo "You must pass a file as an argument, as follows:"
    echo 
    echo "  C:/path/to/your/file.ext"
    echo 
    exit 1
  }
  [ ! -f "${FILE_PATH}" ] && {
    echo "File '${1}' not found"
    echo 
    echo "Make sure the file path has the following format:"
    echo 
    echo "  C:/path/to/your/file.ext"
    echo 
    exit 1
  }
}

function bottle.run(){
  bottle.loadEnvironment
  [ ! -f "${BOTTLE_NAME}/executable" ] && {
    help.youMust "set the main executable" "set-main-executable" "\"C:/path/to/your/application.exe\""
  }
  echo
  echo Starting "$(cat ${BOTTLE_NAME}/executable)"...
  "${HERE}/wineserver"
  "${HERE}"/wine "$(cat ${BOTTLE_NAME}/executable)"
  echo
}

function bottle.loadEnvironment(){
  [ ! -f "${BOTTLE_NAME}/prefix/drive_c/windows/regedit.exe" ] && {
    help.youMust "create a bottle" "create-bottle"
  }
  export WINEARCH=win32
  export WINEPREFIX=$(readlink -m ${BOTTLE_NAME}/prefix)
  export HOME=$(readlink -m "${BOTTLE_NAME}")
  export XDG_CONFIG_HOME="${HOME}/config"
}
