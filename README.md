<h1 align="center">
  <img src="data/Wine.png"></img>
  <br />
  Win32-AppImage | <a href="https://github.com/sudo-give-me-coffee/wine-appimage/releases/tag/continuous">Downloads</a>
</h1>

<p align="center"><i>"A simple and lightweight way to distribute the 32-bit Microsoft Windows® application on Linux"</i>.<br> It works on most Linux
distributions.</p>

<hr>

# Usage:
The **wine32-deploy** Commands

> Note: All commands must receive a bottle name


| Command         |    | What its does                                   |
|-----------------|----|-------------------------------------------------|
| create-bottle   | => | Create a new bottle with default settings       |
| install         | => | Install a software from outside bottle          |
| run             | => | Run a software already on the bottle            |
| --strip         | => | Remove unnecessary resources                    |
| package         | => | Package the bottle as AppImage                  |

Usage per command:

* create-bottle:
```
create-bottle  "Bottle Name"
```
The "Bottle Name" is also "App Name"

* install:
```
install  "Bottle Name" "path/to/file.exe"
```
The "path/to/file.exe" is relative to the current directory, and does not need to be inside  "bottle"

* --strip:
```
--strip  "Bottle Name" resource
```
"resource" can be any of these things:

```
 
  mesa3D   -->  Support for DirectX 8 apps
  windows  -->  Wine hardcoded libs (not recommended in most cases)
  gecko    -->  Trident open source replacement (needed by applications that displays HTML content)
  mono     -->  Open source replacement for .NET Framework (with Windows Forms)
  
```

* run:
```
run  "Bottle Name" "C:\path\to\file.exe"
```
The "C:/path/to/file.exe" must be absolute and you don't need worry about slashes be "\\" or "/" but make sure that starts with "C:" and file exists on "Bottle Name/prefix/drive_c/"

* package:
```
package  "Bottle Name" "C:\path\to\file.exe" "Category" "path/to/icon.png"
```
The "C:/path/to/file.exe" is the main executable of your program and must be absolute and you don't need worry about slashes be "\" or "/" but make sure that starts with "C:" and file exists on "Bottle Name/prefix/drive_c/"

"Category" represents basically what your application does, the valid words is:

```
 
    AudioVideo     Audio        Video    Development    Education    Game
    Graphics       Network      Office   Science        Settings     System
    Utility
 
```
At last "path/to/icon.png" is the icon of your program, the path is relative to current directory, and does not need to be inside  "bottle", but mustbe in PNG format with a recommended 256x256px resolution

<hr>

The **WineLauncher** Commands

| Command           |    | What its does                                   |
|-------------------|----|-------------------------------------------------|
| -copy-app-files   | => | Defines if app files will extracted of AppImage |
| -change-directory | => | Changes directory to app folder before run      |

They receives only "yes" or "no" as value for example:

* To activate -copy-app-files use:
```
    -copy-app-files yes
```

* To deactivate -copy-app-files use:
```
    -copy-app-files yes
```

<hr>

At last, the commands for Wine tools bundled with **wine32-appimage**:


| Command         |    | What its does                                   |
|-----------------|----|-------------------------------------------------|
| winetricks    | => | Open Winetricks                                 |
| winecfg       | => | Open Wine configurator                          |
| regedit       | => | Open Wine register editor                       |
| taskmgr       | => | Open a task manager for wine apps               |
| uninstaller   | => | Open the 'Wine Uninstaller'                     |

* [winetricks](https://wiki.winehq.org/Winetricks)
* [winecfg](https://wiki.winehq.org/Winecfg)
* [regedit](https://wiki.winehq.org/Regedit)
* [taskmgr](https://wiki.winehq.org/Taskmgr)
* [uninstaller](https://wiki.winehq.org/Uninstaller)

# Credits:
* [win32-appimage](LICENSE.md)
* [Hook and preloader](https://github.com/Hackerl)
* [Wine](https://www.winehq.org/)
* [Visual Style](https://www.deviantart.com/lassekongo83/art/Kupo-Finale-for-XP-107950198)

