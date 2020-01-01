<h1 align="center">
  <img src="data/Wine.png"></img>
  <br />
  WINE AppImage | <a href="https://github.com/sudo-give-me-coffee/wine-appimage/releases/tag/continuous">Downloads</a>
</h1>

<p align="center"><i>"A simple, lightweight way to distribute the 32-bit Microsoft Windows® application on Linux"</i>.<br> It works on Ubuntu, Fedora, Debian, their derivates and all other major Linux
distributions.</p>

<hr>

## How to create a bottle

1. Download Wine AppImage by clicking on "**Downloads**" link above and selecting desired version
2. Open a terminal where you has Wine AppImage
3. Turn it executable:
```bash 
chmod +x Wine-*-x86_64.AppImage
```
4. Create an bottle:
```bash 
./Wine-*-x86_64.AppImage create-bottle "My Bottle"
```

5. Modify with winetricks (if needed):
```bash 
./Wine-*-x86_64.AppImage winetricks "My Bottle"
```

6. Install your application:
```bash 
./Wine-*-x86_64.AppImage install "My Bottle" "/path/to/my/application-setup.exe"
```

## How to package as AppImage:

1. First test your application:

```bash 
./Wine-*-x86_64.AppImage run "My Bottle" "C:/Where/Application/was/installed/application.exe"
```

[Under construction]