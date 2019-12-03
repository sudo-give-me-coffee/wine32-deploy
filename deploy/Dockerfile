FROM debian:buster

COPY . /srv/wine-appimage

WORKDIR /srv/wine-appimage
RUN /srv/wine-appimage/deploy/build.sh
