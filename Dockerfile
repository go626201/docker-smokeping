# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.17

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SMOKEPING_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="ironicbadger,sparklyballs"

RUN \
  echo "**** install packages ****" && \
  if [ -z ${SMOKEPING_VERSION+x} ]; then \
    SMOKEPING_VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.17/main/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:smokeping$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add --no-cache \
    bc \
    bind-tools \
    font-noto-cjk \
    openssh-client \
    fcgiwrap \
    smokeping==${SMOKEPING_VERSION} \
    spawn-fcgi \
    ssmtp \
    sudo \
    tcptraceroute \
    ttf-dejavu && \
  echo "**** give setuid access to traceroute & tcptraceroute ****" && \
  chmod a+s /usr/bin/traceroute && \
  chmod a+s /usr/bin/tcptraceroute && \
  echo "**** fix path to cropper.js ****" && \
  sed -i 's#src="/cropper/#/src="cropper/#' /etc/smokeping/basepage.html && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 80

VOLUME /config /data
