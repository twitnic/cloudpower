FROM ubuntu:18.04

MAINTAINER twitnic <kontakt@twitnic.de>

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY config/php.ini /usr/local/etc/php/php.ini

RUN apt-get update \
  && apt-get install -y apache2 \
  software-properties-common \
  git php php-mbstring php-soap php-ssh2 php-curl php-xml mydumper \
  php-mysql php-xdebug php-mail php-mailparse curl \
  php-memcache php-memcached php-gd php-curl php-cli php-json php-bcmath unzip php-zip xclip

# package install is finished, clean up
RUN apt-get clean # && rm -rf /var/lib/apt/lists/*

# Create testing directory
RUN mkdir -p /var/www/cloudpower

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=bin --filename=composer
RUN composer self-update
RUN git config --global http.postBuffer 524288000

# MariaDB
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
RUN add-apt-repository "deb [arch=amd64,arm64,ppc64el] http://mariadb.mirror.liquidtelecom.com/repo/10.4/ubuntu $(lsb_release -cs) main"
RUN apt update -y
RUN apt -y install mariadb-server mariadb-client
COPY config/mysql_answers.txt /tmp/
RUN cat /tmp/mysql_answers.txt | mysql_secure_installation 2>/dev/null

RUN apt-get upgrade -y
