

function extratools.winetricks(){
  bottle.loadEnvironment
  export WINESERVER=${HERE}/wineserver
  export WINE=${HERE}/wine
  ${HERE}/bin/winetricks ${@}
  return ${?}
}

function extratools.runInside(){
  bottle.loadEnvironment
  echo Starting "${1}"...
  "${HERE}/wineserver"
  "${HERE}"/wine "${1}" ${*}
  return ${?}
}