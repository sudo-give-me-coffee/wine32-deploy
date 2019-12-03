FROM debian:buster

COPY . /srv/wine

WORKDIR /srv/wine
RUN chmod +x /srv/wine/deploy/build.sh
RUN /srv/wine/deploy/build.sh
