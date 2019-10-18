FROM ubuntu:18.04

MAINTAINER twitnic <kontakt@twitnic.de>

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY config/php.ini /usr/local/etc/php/php.ini

RUN apt-get update \
  && apt-get install -y apache2 git php php-mbstring php-soap php-ssh2 php-curl php-xml mydumper \
  php-mysql php-xdebug php-mail php-mailparse \
  php-memcache php-memcached php-gd php-curl php-cli php-json php-bcmath unzip php-zip xclip

# package install is finished, clean up
RUN apt-get clean # && rm -rf /var/lib/apt/lists/*

# Create testing directory
RUN mkdir -p /var/www/cloudpower

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=bin --filename=composer
RUN composer self-update
RUN git config --global http.postBuffer 524288000

RUN apt-get upgrade -y
