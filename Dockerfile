FROM ubuntu:18.04

MAINTAINER twitnic <kontakt@twitnic.de>

RUN apt-get update \
  && apt-get install -y ca-certificates curl php apache2 tzdata unzip && \
  apt-get install php-xml
