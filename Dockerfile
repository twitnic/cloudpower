FROM ubuntu:18.04

MAINTAINER twitnic <kontakt@twitnic.de>

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
  && apt-get install -y ca-certificates curl php apache2 tzdata curl php-cli php-mbstring git unzip && \
  apt-get install php-xml
