

function help.main(){
  echo "  Usage:"
  echo "   ${APPIMAGE} [command] [bottle name] [parameter]"
  echo
  echo "  Available commands are:"
  echo
  echo "    Bottle usage commands:"
  echo "      create-bottle       =>  Create a new bottle with default settings"
  echo "      install             =>  Install a software from outside bottle"
  echo "      remove-file         =>  Removes a file from prefix"
  echo "      run                 =>  Run the main executable of bottle"
  echo
  echo "    Bottle modification commands:"
  echo "      set-main-executable =>  Set main executable of bottle"
  echo "      set-name            =>  Set name for application menu name"
  echo "      set-icon            =>  Set icon for AppImage"
  echo "      set-category        =>  Defines where application will appear on menu"
  echo
  echo "    Flags control commands:"
  echo "      enable              =>  Enable a flag"
  echo "      disable             =>  Disable a flag"
  echo "      list-flags          =>  List available flags"
  echo
  echo "    AppDir creation and manipulation commands:"
  echo "      create-appdir       =>  Create an AppDir from bottle¹"
  echo "      test                =>  Test a bottle as AppImage"
  echo "      minimize            =>  Remove uneeded files from bottle"
  echo "      package             =>  Build a AppImage from the bottle AppDir"
  echo
  echo "  To run Wine components and bottle executables, use:"
  echo "        ${APPIMAGE} [bottle name] <component>"
  echo "        ${APPIMAGE} [bottle name] C:/path/to/file.exe"
  echo
  echo "  Tip: You can ommit [bottle name] parameter by exporting a environment"
  echo "       variable with the bottle name, for e.g.:"
  echo 
  echo "        export BOTTLE_NAME=\"MyApp\""
  echo
  echo "-------------------------------------------------------------------------------"
  echo
  echo " ¹ Sometimes the application needs a specific set of registry keys that are"
  echo "   not  viable to be extracted;  therefore. You can bundle all  registry by"
  echo "   passing the --keep-registry parameter to 'create-appdir'"
  echo
}

function help.youMust(){
    echo
    echo "You must ${1} first!"
    echo "It can be done with:"
    echo
    echo "${APPIMAGE} ${2} ${BOTTLE_NAME} ${3}"
    echo
    exit 1
}

function help.categories(){
    echo "A list of valid categories is shown below:"
    echo
    echo "  AudioVideo   Audio  Video  Game  Graphics "
    echo "  Development  Settings  Education   Office "
    echo "  Network      Science   System     Utility "
    echo
    echo "You can find an detailed explanation on following link:"
    echo "  https://specifications.freedesktop.org/menu-spec/latest/apa.html"
    exit 1
}