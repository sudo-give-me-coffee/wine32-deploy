
function appdir.create-appdir(){

  [ ! -f "${BOTTLE_NAME}/executable" ] && {
    help.youMust "set the main executable" "set-main-executable" "\"C:/path/to/your/application.exe\""
  }

  bottle.loadEnvironment
  echo "[ 1/8 ] Creating AppDir..."
  mkdir -p "${BOTTLE_NAME}.AppDir/"
  WINE_FILES=$(ls "${HERE}" | grep -Ev "${BOTTLE_NAME}|${BOTTLE_NAME}.AppDir|.*.sh$|Resources|Wine.png|wine.desktop|Flags|AppRun|appimagetool-x86_64.AppImage")
  
  echo "[ 2/8 ] Copying Wine..."
  echo "        This will take a while..."
  echo "${WINE_FILES}" | sed "s|^|cp -r ${HERE}/|g" | sed "s|$| ${BOTTLE_NAME}.AppDir|g" | sh
  
  echo "[ 3/8 ] Copying bottle..."
  echo "        This will take a while..."
  cp -r ${BOTTLE_NAME}/* ${BOTTLE_NAME}.AppDir
  
  echo "[ 4/8 ] Removing unecessary data..."
  rm -rf ${BOTTLE_NAME}.AppDir/include
  rm -rf ${BOTTLE_NAME}.AppDir/config
  
  echo "[ 5/8 ] Getting added keys to registry..."
  diff ${BOTTLE_NAME}.AppDir/prefix/system.reg ${BOTTLE_NAME}.AppDir/system.reg.orig  | grep ^"< " \
                                                                                      | head -n -44 \
                                                                                      | cut -c 3-|  grep -v ^"#" \
                                                                                      | rev | sed '/^[0-9]\{10\}/ s/ /#   /' \
                                                                                      | rev | sed 's/^\[S/\[HKEY_LOCAL_MACHINE\\S/g' \
                                                                                      | sed '/^\[/ s|\\\\|\\|g' \
                                                                                      |  sed "/\"InstallDate\"/c\{Install date here}" \
                                                                                     >> ${BOTTLE_NAME}.AppDir/default.reg
  rm ${BOTTLE_NAME}.AppDir/system.reg.orig
  rm ${BOTTLE_NAME}.AppDir/prefix/*.reg
  
  # Fixes https://github.com/sudo-give-me-coffee/win32-appimage/issues/7
  [ "${1}" == "--keep-registry" ] && {
    shift
    cp ${BOTTLE_NAME}/prefix/system.reg ${BOTTLE_NAME}.AppDir/prefix/
  }
  
  rm ${BOTTLE_NAME}.AppDir/prefix/.update-timestamp
  rm -rf ${BOTTLE_NAME}.AppDir/prefix/dosdevices
  rm -rf ${BOTTLE_NAME}.AppDir/prefix/drive_c/users
  
  echo "[ 6/8 ] Deduplicating files..."
  file_list=$(find ${BOTTLE_NAME}.AppDir/prefix/drive_c/windows -type f | sort | uniq)
  for file in ${file_list[@]}; do
    [[ -L  "${BOTTLE_NAME}.AppDir/lib/wine/$(basename ${file})" ]] && {
      file="dummy"
    }
    
    [ -f "${BOTTLE_NAME}.AppDir/lib/wine/$(basename ${file})" ] && {
      rm "${BOTTLE_NAME}.AppDir/lib/wine/$(basename ${file})"
      ln -s "../../"$(echo ${file} | sed "s|^${BOTTLE_NAME}.AppDir/||g") "${BOTTLE_NAME}.AppDir/lib/wine/$(basename ${file})"
    }
  done
  rm -rf "${BOTTLE_NAME}.AppDir/lib/wine/fakedlls"
  rm "${BOTTLE_NAME}.AppDir/share/wine/wine.inf"
  
  echo "[ 7/8 ] Creating AppRun..."
  cat "${HERE}/WineAppRun.sh" | sed "s|§bottle|${BOTTLE_NAME}|g" > ${BOTTLE_NAME}.AppDir/AppRun
  chmod +x ${BOTTLE_NAME}.AppDir/AppRun
  
  echo "" >> ${BOTTLE_NAME}.AppDir/flags.sh
  
  for flag in ${BOTTLE_NAME}.AppDir/*.flag; do 
    cat "${flag}" >> ${BOTTLE_NAME}.AppDir/flags.sh 2> /dev/null
    rm ${flag} &> /dev/null 
  done
  
  echo "[ 8/8 ] All AppDir Creation steps is done"
  [ "${1}" == "--no-message" ] && return
  
  echo 
  echo "The nexts steps is:"
  echo 
  echo "  Test your AppDir¹"
  echo "   ${APPIMAGE} test ${BOTTLE_NAME}"
  echo
  echo "  Minimize AppDir to reduce AppImage size²"
  echo "   ${APPIMAGE} minimize ${BOTTLE_NAME}"
  echo
  echo "  Package AppDir in to AppImage"
  echo "   ${APPIMAGE} package path/to/icon.png"
  echo 
  echo "Notes: "
  echo "  ¹ This will create a temporary \${HOME}"
  echo "  ² You will may be asked for root password, it is needed to mount a tmpfs"
  echo 
}

function appdir.test(){
  appdir.hasCreated
  echo "[ 1/3 ] Creating Environment..."
  export HOME=$(mktemp -d)
  export XDG_CONFIG_HOME="${HOME}/config"
  echo
  echo HOME=${HOME}
  echo XDG_CONFIG_HOME=${XDG_CONFIG_HOME}
  echo WINEPREFIX="${XDG_CONFIG_HOME}/${BOTTLE_NAME}"
  echo
  echo "[ 2/3 ] Initializing test..."
  echo
  ${BOTTLE_NAME}.AppDir/AppRun
  echo
  echo "[ 3/3 ] Ending test..."
  echo
  rm -rf ${HOME}
  rm -rf ${XDG_CONFIG_HOME}
}

function appdir.minimize(){
  appdir.hasCreated
  export LANG=en.UTF-8
  echo "[ 1/8 ] Creating Environment..."
  export HOME=$(mktemp -d)
  export XDG_CONFIG_HOME="${HOME}/config"
  export TMPFS_APPDIR=$(mktemp -d)
  echo
  echo HOME=${HOME}
  echo XDG_CONFIG_HOME=${XDG_CONFIG_HOME}
  echo WINEPREFIX="${XDG_CONFIG_HOME}/${BOTTLE_NAME}"
  echo TMPFS_APPDIR="${TMPFS_APPDIR}"
  echo
  
  echo "[ 2/8 ] Mounting tmpfs..."
  sudo mount -t tmpfs tmpfs ${TMPFS_APPDIR} -o strictatime,nodiratime 
  
  echo "[ 3/8 ] Copying ${BOTTLE_NAME}.AppDir to tmpfs..."
  echo "        This will take a while..."
  cp -r ${BOTTLE_NAME}.AppDir/* ${TMPFS_APPDIR}
  
  echo "[ 4/8 ] Initializing test..."
  echo
  REFERENCE_FILE=$(mktemp)
  ${TMPFS_APPDIR}/AppRun
  echo
  
  echo "[ 5/8 ] Getting a list unused files..."
  LIST=$(find ${TMPFS_APPDIR} -mindepth 3 -type f -not -anewer ${REFERENCE_FILE} | sed "s|^${TMPFS_APPDIR}||g")
  WINE_FILES=$(echo   "${LIST}" | grep -v ^"/prefix/")
  PREFIX_FILES=$(echo "${LIST}" | grep ^"/prefix/drive_c/windows/")
  
  echo "[ 6/8 ] Removing unused files..."
  echo "        This may take a while..."
  echo "${WINE_FILES}"   | sed "s|^|rm \"${BOTTLE_NAME}.AppDir|g" | sed "s|$|\"|g" | sh
  echo "${PREFIX_FILES}" | sed "s|^|rm \"${BOTTLE_NAME}.AppDir|g" | sed "s|$|\"|g" | sh
  find "${BOTTLE_NAME}.AppDir" -type l ! -exec test -e {} \; -delete
  find "${BOTTLE_NAME}.AppDir" -type d -empty -delete
  
  [ "${1}" = "--append-to-script" ] && {
    shift
    echo "${WINE_FILES}"   | sed 's/^/  - /g' >> "${1}"
    echo "${PREFIX_FILES}" | sed 's/^/  - /g' >> "${1}"
  }
  
  type strip &> /dev/null && {
    [ "${1}" = "--run-strip" ] && {
      find "${BOTTLE_NAME}.AppDir" -not -path '*/prefix/drive_c/*' | sed 's/^/strip --strip-unneeded "/g' | sed 's/$/"/g' | sh &> /dev/null
    }
  }
  
  echo "[ 7/8 ] Umounting tmpfs..."
  sudo umount ${TMPFS_APPDIR}
  
  echo "[ 8/8 ] Ending test..."
  rm -rf ${HOME}
  rm -rf ${XDG_CONFIG_HOME}
  rm -rf ${TMPFS_APPDIR}
  rm -f  ${REFERENCE_FILE}
}

function appdir.package(){
  appdir.hasCreated
  [ ! "${1}" = "--package-style" ] && {
     rm -r "${BOTTLE_NAME}.AppDir/prefix/drive_c/windows/Resources/Themes/kupofl" 
  }
  ARCH=x86_64 "${HERE}/appimagetool-x86_64.AppImage" --appimage-extract-and-run --no-appstream "${BOTTLE_NAME}.AppDir"
}

function appdir.hasCreated(){
  [ ! -f "${BOTTLE_NAME}.AppDir/default.reg" ] && {
    help.youMust "create a bottle AppDir" "create-appdir"
    exit 1
  }
}

