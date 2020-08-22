
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
  echo "  Minimize AppDir to reduce AppImage size"
  echo "   ${APPIMAGE} minimize ${BOTTLE_NAME}"
  echo
  echo "  Package AppDir in to AppImage²"
  echo "   ${APPIMAGE} package ${BOTTLE_NAME}"
  echo 
  echo "Notes: "
  echo "  ¹ This will create a temporary \${HOME} and run the application inside"
  echo "    it simulating a environment that never has ran a Wine application before"
  echo "  ² You will probably want to check for any missing DLLs, to do it run:"
  echo "      ${APPIMAGE} search-for-missing-dlls ${BOTTLE_NAME}"
  echo 
}

function appdir.test(){
  appdir.hasCreated
  echo "[ 1/3 ] Creating Environment..."
  export HOME=$(mktemp -d)
  export XDG_CONFIG_HOME="${HOME}/config"
  export XDG_DATA_HOME="${HOME}/data"
  export LANG=en.UTF-8
  echo
  echo HOME=${HOME}
  echo XDG_CONFIG_HOME=${XDG_CONFIG_HOME}
  echo XDG_DATA_HOME="${XDG_DATA_HOME}"
  echo WINEPREFIX="${XDG_CONFIG_HOME}/${BOTTLE_NAME}"
  echo
  echo "[ 2/3 ] Initializing test..."
  echo
  mkdir -p "${XDG_DATA_HOME}"
  ${BOTTLE_NAME}.AppDir/AppRun
  echo
  echo "[ 3/3 ] Ending test..."
  echo
  rm -rf ${HOME}
  rm -rf ${XDG_CONFIG_HOME}
  rm -rf ${XDG_DATA_HOME}
}

function appdir.minimize(){
  appdir.hasCreated
  export LANG=en.UTF-8
  
  export WINEDEBUG=+file
  
  echo "[ 1/5 ] Creating Environment..."
  export HOME=$(mktemp -d)
  export XDG_CONFIG_HOME="${HOME}/config"
  export XDG_DATA_HOME="${HOME}/data"
  export TMPFS_APPDIR=$(mktemp -d)
  export WINEPREFIX="${XDG_CONFIG_HOME}/${BOTTLE_NAME}"
  echo
  echo HOME=${HOME}
  echo XDG_CONFIG_HOME=${XDG_CONFIG_HOME}
  echo XDG_DATA_HOME="${XDG_DATA_HOME}"
  echo WINEPREFIX="${XDG_CONFIG_HOME}/${BOTTLE_NAME}"
  echo TMPFS_APPDIR="${TMPFS_APPDIR}"
  echo

  REFERENCE_FILE=$(mktemp)
  
  echo "[ 2/5 ] Initializing test..."
  used_files_symlink=($(${BOTTLE_NAME}.AppDir/AppRun | grep -i "c:/windows" \
                                                     | grep "wine_nt_to_unix_file_name" \
                                                     | cut -d\" -f4 | sort | uniq))
                                                     
  echo "[ 3/5 ] Fetching bottle unused files..."
  for file in "${used_files_symlink[@]}"; do
    real_file=$(readlink -f "${file}")
    [ -f "${real_file}" ] && {
      touch "${real_file}"
    }
  done
   
  echo "[ 4/5 ] Removing unused files..."
  
  cd "${BOTTLE_NAME}.AppDir"
  
  # Remove unneeded Wine DLLs
  [ "${1}" = "--append-to-script" ] && {
    delete_list_dlls=$(find ./"prefix/drive_c/windows" -type f -not -anewer ${REFERENCE_FILE} -print)
  }
  find ./"prefix/drive_c/windows" -type f -not -anewer ${REFERENCE_FILE} -delete

  used_files=($(cat used_files | grep -v ENOENT | cut -d\" -f2 | grep "/${BOTTLE_NAME}.AppDir/" | sort | uniq | grep -v "z:"))
  for file in "${used_files[@]}"; do
    [ -f "${file}" ] && {
      # Strace doesn't translate symlinks, so is needed replace the symlink with real file
      [ -L "${file}" ] && {
        real_file=$(readlink -f "${file}")
        [ ! "${file}" = "${real_file}" ] && {
          rm "${file}"
          cp "${real_file}" "${file}"
          rm "${real_file}"
        }
      }
      touch "${file}"
    }
  done
  
  # libgcc_s.so.1 is required to automatically close Wine after exiting the application
  touch ./"lib/i386-linux-gnu/libgcc_s.so.1"

  # Remove unused files except under "prefix" to avoid delete application files
  [ "${1}" = "--append-to-script" ] && {
    delete_list_files=$(find . -mindepth 3 -type f -not -path "*/prefix/*" -not -anewer ${REFERENCE_FILE} -print)
  }
  find . -mindepth 3 -type f -not -path "*/prefix/*" -not -anewer ${REFERENCE_FILE} -delete
  
  # Remove empty directories
  find . -type d -empty -delete
  
  # Remove broken symlinks
  [ "${1}" = "--append-to-script" ] && {
    delete_list_symlinks=$(find . -type l ! -exec test -e {} \; -print)
  }
  find . -type l ! -exec test -e {} \; -delete
  
  # Remove old installers and temporary files
  find ./"prefix/drive_c/windows/Installer" -type f -delete
  find ./"prefix/drive_c/windows/temp" -type f -delete
                               
  echo "[ 5/5 ] Ending test..."
  rm -rf ${HOME}
  rm -rf ${XDG_CONFIG_HOME}
  rm -rf ${TMPFS_APPDIR}
  rm -f  ${REFERENCE_FILE}
  rm -rf ${XDG_DATA_HOME}
  
  [ "${1}" = "--append-to-script" ] && {
    echo 'Finishing "dist" recipe...'
    unneeded_files=$(echo -e "${delete_list_dlls}\n${delete_list_files}\n${delete_list_symlinks}")
    cd ..
    echo "${unneeded_files}" | cut -c 2- | sed 's|^|  - |g' >> "${2}"
  }
}

function appdir.package(){
  appdir.hasCreated
  [ ! "${1}" = "--package-style" ] && {
    [ -f "${BOTTLE_NAME}.AppDir/prefix/drive_c/windows/Resources/Themes/kupofl" ] && {
      rm -r "${BOTTLE_NAME}.AppDir/prefix/drive_c/windows/Resources/Themes/kupofl" 
    }
  }
  [ -f "${BOTTLE_NAME}.AppDir/prefix/drive_c/windows/system32/winemenubuilder.exe" ] && {
    rm "${BOTTLE_NAME}.AppDir/prefix/drive_c/windows/system32/winemenubuilder.exe"
  }
  ARCH=x86_64 "${HERE}/appimagetool-x86_64.AppImage" --appimage-extract-and-run --no-appstream "${BOTTLE_NAME}.AppDir"
}

function appdir.hasCreated(){
  [ ! -f "${BOTTLE_NAME}.AppDir/default.reg" ] && {
    help.youMust "create a bottle AppDir" "create-appdir"
    exit 1
  }
}

function appdir.search-for-missing-dlls(){
  echo "Starting test to fetch missing DLLs..."
  missing_dlls=($("${BOTTLE_NAME}.AppDir/AppRun" | grep import | cut -d' ' -f3 | sort | uniq))
  
  for dll in ${missing_dlls[@]};do
    echo "Fixing missing DLL dependency ${dll,,}"
    cp "${HERE}/lib/wine/${dll,,}" "${BOTTLE_NAME}.AppDir/lib/wine/"
    cp "${HERE}/lib/wine/${dll,,}" "${BOTTLE_NAME}.AppDir/prefix/drive_c/windows/system32"
  done
}

