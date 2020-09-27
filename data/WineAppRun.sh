#!/usr/bin/env bash

HERE="$(dirname "$(readlink -f "${0}")")"

[ "${HOME}" = "" ] && {
  export HOME=$(mktemp -d)
}

# Make sure that USER is set
[ "${USER}" = "" ] && {
  export USER=$(basename "${HOME}")
}

[ "${XDG_CONFIG_HOME}" = "" ] && {
  export XDG_CONFIG_HOME="${HOME}/.config"
}

# Make sure that XDG_DATA_HOME is set
[ "${XDG_DATA_HOME}" = "" ] && {
  export XDG_DATA_HOME="${HOME}/.local/share"
  mkdir -p "${XDG_DATA_HOME}"
}

export WINEARCH=win32
export WINEPREFIX="${XDG_CONFIG_HOME}/SumatraPDF"


# Some Languages uses symbols that breakes Wine
export LANG=en.UTF-8

mkdir -p "${WINEPREFIX}/drive_c"

. ${HERE}/flags.sh

for file in "${HERE}"/prefix/drive_c/*; do
  item=$(basename "${file}")
  unlink "${WINEPREFIX}/drive_c/${item}" &> /dev/null
  ln -fs "${file}" "${WINEPREFIX}/drive_c" &> /dev/null
done

"${HERE}/wineserver"

[ ! -f "${WINEPREFIX}/system.reg" ] && {
  TODAY="$(date '+%Y%m%d')"
  cp "${HERE}/default.reg" --no-clobber "${WINEPREFIX}/"
  sed -i "s/{Install date here}/\"InstallDate\"=\"${TODAY}\"/g" "${WINEPREFIX}/default.reg"

  mkdir -p "${WINEPREFIX}/drive_c/users/${USER}/"
  ln -s "${WINEPREFIX}/drive_c/users/${USER}/" "${WINEPREFIX}/drive_c/users/999"
  ln -s "$(xdg-user-dir DESKTOP)" "${WINEPREFIX}/drive_c/users/${USER}/Desktop"
  
  ${HERE}/wine regedit "${WINEPREFIX}/default.reg"
  rm "${WINEPREFIX}/default.reg"
  
  [ -f "${HERE}/prefix/system.reg" ] && {   
    cat "${HERE}/prefix/system.reg" | grep -v ^"\[Software\\Microsoft\\Cryptography" -A 2 \
                                    | grep -v ^"WINE REGISTRY Version 2" >> "${WINEPREFIX}/system.reg"
                                    
  }
    
  echo '[Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders]'   >> "${WINEPREFIX}/user.reg"
  echo '"Personal"=str(2):"%USERPROFILE%\\'$(basename "$(xdg-user-dir DOCUMENTS)")'"'   >> "${WINEPREFIX}/user.reg"

  ln -s "${HOME}" "${WINEPREFIX}"/drive_c/users/${USER}/$(basename "$(xdg-user-dir DOCUMENTS)")
}

echo
echo HOME=${HOME}
echo XDG_CONFIG_HOME=${XDG_CONFIG_HOME}
echo XDG_DATA_HOME=${XDG_DATA_HOME}
echo WINEPREFIX=${WINEPREFIX}
echo

${HERE}/wine "$(cat ${HERE}/executable)" ${@}
exit ${?}
