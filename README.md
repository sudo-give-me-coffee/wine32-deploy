<h1 align="center">
  <img src="data/Wine.png"></img>
  <br />
  WINE AppImage | <a href="https://github.com/sudo-give-me-coffee/wine-appimage/releases/tag/continuous">Downloads</a>
</h1>

<p align="center"><i>"A simple, lightweight way to distribute the 32-bit Microsoft Windows® application on Linux"</i>.<br> It works on Ubuntu, Fedora, Debian, their derivates and all other major Linux
distributions.</p>

<hr>

## How it works?

Just 8 steps is needed (a 6 step version coming soon) to port a Windows 32 bit application to Linux!

##### 1. Download Wine AppImage by clicking on "**Downloads**" link above and selecting desired version
##### 2. Open a terminal where you has Wine AppImage
##### 3. Turn it executable:
```bash 
chmod +x Wine-*-x86_64.AppImage
```
##### 4. Install your application with Wine AppImage, for example:
```bash 
./Wine-*-x86_64.AppImage "/path/to/your/App_setup.exe"
```
##### 5. Make your app work (if it doesn't work with Wine upstream):

Wine AppImage comes with Winetricks bundled, to run it execute:

```bash 
./Wine-*-x86_64.AppImage winetricks
```
> Note: It requires Zenity installed on your system to use graphical interface

##### 6. Write a YAML describing assets to your application:

```YAML
app: VisualG 2.5
icon: visualg.png
executable: c:\Apoio\VisualG_2.5\visualg.exe
categories: Development; Education
strip: --purge-mono --purge-mesa3D
```
> Note: for more info run this line:

```
./Wine-*-x86_64.AppImage deploy --help
```

##### 7. Run these line to generate AppDir:

```
./Wine-*-x86_64.AppImage deploy visualg_2.5.yml
```

##### 8. Finish it [with appimagetool](https://appimage.github.io/appimagetool/)




### Goals

- [x] Fully functional AppImage for newer WINE versions
- [x] An quick prefix deploy tool
- [x] Make a easy-to-implement way for readonly prefixes (no FUSE dependent)
- [x] A tool to purge unneeded files
- [ ] Documentation

### 
