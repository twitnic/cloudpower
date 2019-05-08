FROM php:7.1-apache

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
     libpng12-dev \
     libfreetype6-dev \
     libjpeg-dev \
  && apt-get clean \
  && rm -r /var/lib/apt/lists/*
