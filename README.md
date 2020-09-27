<h1 align="center">
  <img src="data/Wine.png"></img>
  <br />
  Win32-AppImage | <a href="https://github.com/sudo-give-me-coffee/wine-appimage/releases/tag/continuous">Downloads</a> | <img src="https://api.travis-ci.org/sudo-give-me-coffee/wine32-deploy.svg?branch=master"></img>
</h1>

<p align="center"><i>"A simple and lightweight way to distribute the 32-bit Microsoft Windows® application on Linux"</i>.<br> It works on most Linux
distributions.</p>

<hr>

# Usage:
The **wine32-deploy** Commands

### Bottle usage commands:

| Command         |    | What its does                                   |
|-----------------|----|-------------------------------------------------|
| create-bottle   | => | Create a new bottle with default settings       |
| install         | => | Install a software from outside bottle          |
| run             | => | Run the bottle as AppImage                      |

* create-bottle:
```
create-bottle  "Bottle Name"
```

* install:
```
install  "Bottle Name" "path/to/file.exe"
```
The "path/to/file.exe" is relative to the current directory, and does not need to be inside  "bottle"

* run:
```
run  "Bottle Name"
```
You must set a "main executable" first

### Bottle modification commands:

| Command               |    | What its does                       |
|-----------------------|----|-------------------------------------|
| set-main-executable   | => | Set main executable of bottle       |
| set-name              | => | Set name for application menu name  |
| set-icon              | => | Set icon for AppImage               |
| set-category          | => | Defines where application will appear on menu               |

* set-main-executable:
```
set-main-executable "Bottle Name" "C:\path\to\file.exe"
```
The "C:/path/to/file.exe" is the main executable of your program, and follow some rules:
1. Must be absolute
2. You don't need worry about slashes be "\\" or "/" 
3. Make sure that parameter starts with "C:" and file exists on "Bottle Name/prefix/drive_c/"

* set-name:
```
set-name "Bottle Name" "New App Name"
```

* set-icon:
```
set-icon "Bottle Name" "path/to/icon.png"
```
"path/to/icon.png" is the icon of your program, the path is relative to current directory, and does not need to be inside  "bottle", but must be in PNG format with a recommended 256x256px resolution

* set-category:
```
set-category "Bottle Name" "Category"
```
"Category" is the category of your program, in Linux this will determine where your Application will appear on Menu

```
 
    AudioVideo     Audio        Video    Development    Education    Game
    Graphics       Network      Office   Science        Settings     System
    Utility
 
```


<hr>

### Flags control commands:

| Command      |    | What its does          |
|--------------|----|------------------------|
| enable       | => | Enable a flag          |
| disable      | => | Set icon for AppImage  |
| list-flags   | => | List available flags   |

Flags modify behavior of packaged apps

* enable:
```
enable "Bottle Name" copy-app-files
```

Enable flag "copy-app-files"

* disable:
```
disable "Bottle Name" copy-app-files
```

Disable flag "copy-app-files"

* list-flags:
```
list-flags
```
List supported flags and what they do

### AppDir creation and manipulation commands:

| Command       |    | What its does                           |
|---------------|----|-----------------------------------------|
| create-appdir | => | Create an AppDir from bottle            |
| minimize      | => | Remove uneeded files from bottle        |
| test          | => | Test a bottle as AppImage               |
| package       | => | Build a AppImage from the bottle AppDir |

Flags modify behavior of packaged apps

* create-appdir:
```
create-appdir "Bottle Name"
```
If application does verification of DLL sigatures you must pass `--keep-registry` parameter

* minimize:
```
minimize "Bottle Name"
```
This command allows the quick removal of unnecessary Wine files for the application to run

* test:
```
test "Bottle Name"
```
This command allows test application simulating a real user HOME, before packaging AppImage

* package:
```
package "Bottle Name"
```
Simplified way to build an AppImage from the bottle



## Useful tools

| Command       |    | What its does                                   |
|---------------|----|-------------------------------------------------|
| winecfg       | => | Open Wine configurator                          |
| regedit       | => | Open Wine register editor                       |
| taskmgr       | => | Open a task manager for wine apps               |
| uninstaller   | => | Open the 'Wine Uninstaller'                     |

* [winetricks](https://wiki.winehq.org/Winetricks)
* [winecfg](https://wiki.winehq.org/Winecfg)
* [regedit](https://wiki.winehq.org/Regedit)
* [taskmgr](https://wiki.winehq.org/Taskmgr)
* [uninstaller](https://wiki.winehq.org/Uninstaller)

# Building AppImage from source
All you need is the `docker` and `git`, most linux distributions have it in the repository, once time installed, you need 5 steps:

1. Clone repository and enter on repository (if you don't did it):
```
git clone https://github.com/sudo-give-me-coffee/wine32-deploy.git
cd wine32-deploy
```
2. Turn the build script executable:
```
chmod +x build.sh
```
3. Run docker:
```
docker build . -t wine.appimage
```
4. Copy AppImage to current dir and remove original file:
```
sudo cp "$(sudo find /var/lib/docker -name 'Wine-*x86_64.AppImage')" .
sudo rm "$(sudo find /var/lib/docker -name 'Wine-*x86_64.AppImage')" .
```
4. Make AppImage executable:
```
sudo chmod 777 Wine-*x86_64.AppImage
```

# Credits:
* [win32-appimage](LICENSE.md)
* [Hook and preloader](https://github.com/Hackerl)
* [Wine](https://www.winehq.org/)
* [Visual Style](https://www.deviantart.com/lassekongo83/art/Kupo-Finale-for-XP-107950198)
* [Minimize](https://github.com/sudo-give-me-coffee/win32-appimage/issues/5#issuecomment-576017985)

