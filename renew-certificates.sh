#!/bin/bash

cd  "${BASH_SOURCE%/*}" || exit
docker pull certbot/certbot
docker run --rm -v "${PWD}/certbot:/etc/letsencrypt" -v "${PWD}/certbot/www:/var/www/certbot" certbot/certbot renew -n
docker-compose pull
docker-compose stop
docker-compose up -d
