FROM ubuntu:18.04

MAINTAINER twitnic <kontakt@twitnic.de>

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
     libpng12-dev \
     libfreetype6-dev \
     libjpeg-dev \
  && apt-get clean \
  && rm -r /var/lib/apt/lists/*
