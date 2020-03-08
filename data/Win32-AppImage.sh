
#---------------------------------------------------------------------------

. ${HERE}/BottleTool.sh
. ${HERE}/AppDirTool.sh
. ${HERE}/FlagsTool.sh
. ${HERE}/Help.sh

#---------------------------------------------------------------------------

type bottle.${OPTION} &> /dev/null && {
  bottle.${OPTION} "${1}" "${2}"
  exit ${?}
}

type flags.${OPTION} &> /dev/null && {
  flags.${OPTION} "${1}"
  exit ${?}
}

type appdir.${OPTION} &> /dev/null && {
  appdir.${OPTION} "${1}"
  exit ${?}
}

help.main

[ "${OPTION}" = "--help" ] && exit 0 || exit 1
