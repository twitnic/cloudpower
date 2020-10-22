FROM ubuntu:18.04

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
RUN mkdir -p /var/www/cloudpower

RUN apt-get update && apt-get install --no-install-recommends -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i de_DE -c -f UTF-8 -A /usr/share/locale/locale.alias de_DE.UTF-8
ENV LANG de_DE.utf8

RUN apt update && apt dist-upgrade -y
RUN apt install software-properties-common -y
RUN add-apt-repository ppa:ondrej/php
RUN apt update

RUN apt-get update \
  && apt-get install --no-install-recommends -y apache2 \
  software-properties-common nano \
  git git-core make ssh openssh-client php7.3 php-dev php7.3-mbstring php-imap php7.3-soap php-intl php7.3-ssh2 php7.3-curl php7.3-xml mydumper \
  php7.3-mysql php7.3-xdebug php-pear php7.3-mail php7.3-mailparse mariadb-client curl wget \
  php7.3-memcache php7.3-memcached php7.3-gd php7.3-cli php7.3-json php7.3-bcmath unzip php7.3-zip xclip

#RUN a2dismod php7.2
#RUN a2dismod php7.4
RUN a2enmod php7.3

RUN update-alternatives --set php /usr/bin/php7.3
RUN update-alternatives --set phar /usr/bin/phar7.3
RUN update-alternatives --set phar.phar /usr/bin/phar.phar7.3
RUN update-alternatives --set phpize /usr/bin/phpize7.3
RUN update-alternatives --set php-config /usr/bin/php-config7.3

RUN apt-get update && apt-get upgrade

RUN ssh-keyscan github.com > /root/.ssh/known_hosts

RUN apt-get install --no-install-recommends libmcrypt-dev -y

RUN pecl channel-update pecl.php.net
RUN mkdir -p /tmp/pear/cache
RUN pecl install mcrypt-1.0.3
RUN echo "extension=mcrypt.so" >> /etc/php/7.3/mods-available/mcrypt.ini
RUN phpenmod mcrypt

RUN mkdir -p /tmp/sepa/libsepa
RUN cd /tmp/sepa
RUN wget https://libsepa.com/downloads/libsepa-2.17-64bit.tar.gz
RUN tar -xvzf libsepa-2.17-64bit.tar.gz -C /tmp/sepa/libsepa
RUN cp /tmp/sepa/libsepa/Linux/64bit/php-7.3/sepa.so /usr/lib/php/20190902/

COPY config/php.ini /usr/local/etc/php/php.ini
COPY config/xdebug.ini /etc/php/7.3/mods-available/xdebug.ini
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
