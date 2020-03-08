#!/usr/bin/env bash

HERE="$(dirname "$(readlink -f "${0}")")"

[ "${XDG_CONFIG_HOME}" = "" ] && {
  export XDG_CONFIG_HOME="${HOME}/.config"
}

export WINEARCH=win32
export WINEPREFIX="${XDG_CONFIG_HOME}/§bottle"

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
  cp "${HERE}/default.reg" "${WINEPREFIX}/"
  sed -i "s/{Install date here}/\"InstallDate\"=\"${TODAY}\"/g" "${WINEPREFIX}/default.reg"
  
  ${HERE}/wine regedit "${WINEPREFIX}/default.reg"
  rm "${WINEPREFIX}/default.reg"
  
  [ -f "${HERE}/prefix/system.reg" ] && {   
    cat "${HERE}/prefix/system.reg" | grep -v ^"\[Software\\Microsoft\\Cryptography" -A 2 \
                                    | grep -v ^"WINE REGISTRY Version 2" >> "${WINEPREFIX}/system.reg"
  }
}

${HERE}/wine "$(cat ${HERE}/executable)" ${@}
exit ${?}
