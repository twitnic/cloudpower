FROM ubuntu:18.04

MAINTAINER twitnic <kontakt@twitnic.de>

ENV DEBIAN_FRONTEND noninteractive

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y

RUN mkdir /root/.ssh
RUN touch ~/.ssh/known_hosts && if [ $(grep -c 'github.com ssh-rsa' ~/.ssh/known_hosts) -lt 1 ]; then KEYS=$(KEYS=$(ssh-keyscan github.com 2>&1 | grep -v '#'); ssh-keygen -lf <(echo $KEYS) || echo $KEYS); if [[ $KEYS =~ '(RSA)' ]]; then if [ $(curl -s https://help.github.com/en/github/authenticating-to-github/githubs-ssh-key-fingerprints | grep -c $(echo $KEYS | awk '{print $2}')) -gt 0 ]; then echo '[GitHub key successfully verified]' && ssh-keyscan github.com 1>~/.ssh/known_hosts; fi; else echo \"ssh-keygen -lf failed:\\n$KEYS\"; exit 1; fi; unset KEYS; fi

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i de_DE -c -f UTF-8 -A /usr/share/locale/locale.alias de_DE.UTF-8
ENV LANG de_DE.utf8

RUN apt-get update \
  && apt-get install -y apache2 \
  software-properties-common nano \
  git php php-mbstring php-soap php-ssh2 php-curl php-xml mydumper \
  php-mysql php-xdebug php-mail php-mailparse curl wget \
  php-memcache php-memcached php-gd php-curl php-cli php-json php-bcmath unzip php-zip xclip

RUN mkdir -p /tmp/sepa/libsepa
RUN cd /tmp/sepa
RUN wget https://libsepa.com/downloads/libsepa-2.17-64bit.tar.gz
RUN tar -xvzf libsepa-2.17-64bit.tar.gz -C /tmp/sepa/libsepa
RUN cp /tmp/sepa/libsepa/Linux/64bit/php-7.2/sepa.so /usr/lib/php/20170718/

COPY config/php.ini /usr/local/etc/php/php.ini
COPY config/xdebug.ini /etc/php/7.2/mods-available/xdebug.ini
COPY config/cloudpower.conf /etc/apache2/sites-available/cloudpower.conf

RUN a2ensite cloudpower.conf
RUN a2dissite 000-default.conf
RUN a2enmod rewrite
RUN a2enmod vhost_alias
ENV APACHE_SERVERNAME docker.intra
ENV APACHE_SERVERALIAS docker.local
RUN echo "ServerName docker.intra" | tee /etc/apache2/conf-available/servername.conf
RUN apache2ctl restart


# package install is finished, clean up
RUN apt-get clean # && rm -rf /var/lib/apt/lists/*

# Create testing directory
RUN mkdir -p /var/www/cloudpower

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=bin --filename=composer
RUN composer self-update
RUN git config --global http.postBuffer 524288000

RUN apt-get upgrade -y

EXPOSE 80
EXPOSE 9000
CMD apachectl -D FOREGROUND