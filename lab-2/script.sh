#!/bin/bash
sudo apt update

sudo apt upgrade -y

sudo apt install ca-certificates curl gnupg lsb-release -y

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo docker --version

sudo docker network create labwebsite-net

sudo docker run -d --name labwebsitedb \
  --network labwebsite-net \
  -e MYSQL_ROOT_PASSWORD=1admin9 \
  -e MYSQL_USER=admin \
  -e MYSQL_PASSWORD=1admin9 \
  -e MYSQL_DATABASE=labwebsitedb \
  -v websitedbvolume:/var/lib/mysql \
  mariadb:latest

mkdir public_html

echo "<?php phpinfo(); ?>" > public_html/index.php

sudo docker run -d --name website \
  --network labwebsite-net \
  -v $(pwd)/public_html:/var/www/html \
  -p 8080:80 \
  php:apache

http://localhost:8080

mkdir lab-contenedores
cd lab-contenedores


mkdir public_html
echo "<?php phpinfo(); ?>" > public_html/index.php

nano docker-compose.yml

version: '3'

services:
  website:
    image: php:apache
    container_name: website
    ports:
      - 8081:80
    volumes:
      - ./public_html:/var/www/html
    networks:
      - labwebsite-net

  labwebsitedb:
    image: mariadb:latest
    container_name: labwebsitedb
    volumes:
      - websitedbvolume:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: "1admin9"
      MYSQL_USER: "admin"
      MYSQL_PASSWORD: "1admin9"
      MYSQL_DATABASE: "labwebsitedb"
    networks:
      - labwebsite-net

networks:
  labwebsite-net:

volumes:
  websitedbvolume:

sudo docker compose up -d

mkdir imagen-personalizada
cd imagen-personalizada

nano Dockerfile

FROM php:8.1-apache
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libicu-dev \
        libxml2-dev \
        vim \
        wget \
        unzip \
    && docker-php-ext-install -j$(nproc) iconv intl opcache \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql exif gettext mysqli

CTRL+O → Enter → CTRL+X

sudo docker build -t miprimeraimagen:v1 .

sudo docker run -d --name prueba-imagen \
  -p 8082:80 \
  miprimeraimagen:v1

http://localhost:8082