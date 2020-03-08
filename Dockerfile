FROM debian:buster

COPY . /srv/wine

WORKDIR /srv/wine

RUN /srv/wine/build.sh
