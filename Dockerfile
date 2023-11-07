FROM ubuntu:22.04

MAINTAINER twitnic <kontakt@twitnic.de>

ENV DEBIAN_FRONTEND noninteractive

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y

RUN mkdir /root/.ssh
RUN touch ~/.ssh/known_hosts

# Create testing directory
RUN mkdir -p /var/www/cloudpower/publc

RUN apt-get update && apt-get install --no-install-recommends -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i de_DE -c -f UTF-8 -A /usr/share/locale/locale.alias de_DE.UTF-8
ENV LANG de_DE.utf8

RUN apt update && apt dist-upgrade -y
RUN apt install software-properties-common -y
#RUN add-apt-repository ppa:ondrej/php
RUN apt update

RUN apt-get update \
  && apt-get install --no-install-recommends -y apache2 \
  software-properties-common nano \
  git git-core make ssh openssh-client php8.1 php8.1-dev php8.1-mbstring php8.1-imap php8.1-soap php-intl php8.1-ssh2 php8.1-curl php8.1-xml mydumper \
  php8.1-mysql php8.1-intl php8.1-xdebug php-pear php8.1-mail php8.1-mailparse mariadb-client curl wget \
  php8.1-memcache php8.1-memcached php8.1-gd php8.1-cli php-json php8.1-bcmath unzip php8.1-zip xclip

#RUN a2dismod php7.2
#RUN a2dismod php7.4
RUN a2enmod php8.1

RUN update-alternatives --set php /usr/bin/php8.1
RUN update-alternatives --set phar /usr/bin/phar8.1
RUN update-alternatives --set phar.phar /usr/bin/phar.phar8.1
#RUN update-alternatives --set phpize /usr/bin/phpize8.1
#RUN update-alternatives --set php-config /usr/bin/php-config8.1

RUN apt-get update -y && apt-get upgrade -y

RUN ssh-keyscan github.com > /root/.ssh/known_hosts

RUN apt-get install --no-install-recommends libmcrypt-dev -y

RUN pecl channel-update pecl.php.net
RUN mkdir -p /tmp/pear/cache
RUN pecl install mcrypt-1.0.6
RUN echo "extension=mcrypt.so" >> /etc/php/8.1/mods-available/mcrypt.ini
# /usr/lib/php/20190902/mcrypt.so
RUN phpenmod mcrypt

RUN apt-get update -y && apt-get upgrade -y

#RUN mkdir -p /tmp/sepa/libsepa
#RUN cd /tmp/sepa
#RUN wget https://libsepa.com/downloads/libsepa-2.25-64bit.tar.gz
#RUN tar -xvzf libsepa-2.25-64bit.tar.gz -C /tmp/sepa/libsepa
#RUN cp /tmp/sepa/libsepa/Linux/64bit/php-8.1/sepa.so /usr/lib/php/20210902/

COPY config/php.ini /usr/local/etc/php/php.ini
COPY config/xdebug.ini /etc/php/8.1/mods-available/xdebug.ini
COPY config/cloudpower.conf /etc/apache2/sites-available/cloudpower.conf

RUN a2ensite cloudpower.conf
RUN a2dissite 000-default.conf
RUN a2enmod rewrite
RUN a2enmod vhost_alias
ENV APACHE_SERVERNAME host.docker.internal
ENV APACHE_SERVERALIAS docker.local
RUN echo "ServerName host.docker.internal" | tee /etc/apache2/conf-available/servername.conf
RUN apache2ctl restart


# package install is finished, clean up
RUN apt-get clean # && rm -rf /var/lib/apt/lists/*

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=bin --filename=composer
RUN composer self-update
RUN git config --global http.postBuffer 524288000

RUN apt-get upgrade -y

EXPOSE 80
CMD apachectl -D FOREGROUND
