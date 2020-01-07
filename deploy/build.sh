#!/usr/bin/env bash

# Setup environment

export ARCH="x86_64"
export Version="4.21"
export BuildDependencies="aptitude wget file gzip bzip2 curl cabextract"
export WorkingDir="Wine.AppDir"
export PackagesDirectory='/tmp/.cache'
export wgetOptions="-nv -c --show-progress --progress=bar:force:noscroll"
export DownloadURLs=(
  "https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-x86/PlayOnLinux-wine-${Version}-upstream-linux-x86.tar.gz"
  "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
  "https://github.com/Hackerl/Wine_Appimage/releases/download/v0.9/libhookexecv.so"
  "https://github.com/Hackerl/Wine_Appimage/releases/download/v0.9/wine-preloader_hook"
  "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"
  )

# Install build deps

dpkg --add-architecture i386
apt update
apt install ${BuildDependencies} -y

# Create Directories

mkdir -p "${WorkingDir}/kupofl"
mkdir -p "${PackagesDirectory}"

# Download files

wget ${wgetOptions} ${DownloadURLs[@]}

# Turn executable

chmod +x "appimagetool-x86_64.AppImage"
chmod +x "data/AppRun"
chmod +x "data/wine"
chmod +x "data/strip"
chmod +x "data/WineLauncher"
chmod +x "wine-preloader_hook"
chmod +x "winetricks"

# Get WINE deps

aptitude -y -d -o dir::cache::archives="${PackagesDirectory}" install libwine:i386
wget -q "http://ftp.us.debian.org/debian/pool/main/libp/libpng/libpng12-0_1.2.50-2+deb8u3_i386.deb" -O "${PackagesDirectory}/libpng12.deb"

# Extract WINE

tar -xzf "PlayOnLinux-wine-${Version}-upstream-linux-x86.tar.gz" -C "${WorkingDir}" || \
tar -xjf "PlayOnLinux-wine-${Version}-upstream-linux-x86.tar.gz" -C "${WorkingDir}"

# Copy wine dependencies to AppDir

find "${PackagesDirectory}" -name '*deb' ! -name 'libwine*' -exec dpkg -x {} "./${WorkingDir}" \;

# Copy data to AppDir

cp data/* "${WorkingDir}"
mv "libhookexecv.so" "${WorkingDir}/bin"
mv "wine-preloader_hook" "${WorkingDir}/bin"
mv "winetricks" "${WorkingDir}/bin"
mv "${WorkingDir}/kupofl.msstyles" "${WorkingDir}/kupofl/"
cp "$(which cabextract)" "${WorkingDir}/bin"

# Build AppImage

./appimagetool-x86_64.AppImage --appimage-extract
./squashfs-root/AppRun "${WorkingDir}"
mv "Wine-x86_64.AppImage" "Wine-${Version}-x86_64.AppImage"

exit
