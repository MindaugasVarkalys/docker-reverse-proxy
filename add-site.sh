#!/bin/bash

PORT=80

# Parse arguments
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -d|--domain)
    DOMAIN="$2"
    shift
    shift
    ;;
    -e|--email)
    EMAIL="$2"
    shift
    shift
    ;;
    -c|--container)
    CONTAINER="$2"
    shift
    shift
    ;;
    -p|--port)
    PORT="$2"
    shift
    shift
    ;;
esac
done

# Check required variables
if [ -z "$DOMAIN" ]
then
    echo "--domain is not specified"
    exit 1
fi
if [ -z "$EMAIL" ]
then
    echo "--email is not specified"
    exit 1
fi
if [ -z "$CONTAINER" ]
then
    CONTAINER=${DOMAIN//./}_web_1
fi


# Add nginx config for certbot verification
cp nginx/TEMPLATE_CERTBOT nginx/"$DOMAIN".conf

# Replace domain placeholder with actual domain
sed -i "s/DOMAIN/$DOMAIN/g" nginx/"$DOMAIN".conf

docker-compose restart

# Get certificate using certbot image
docker run -it --rm -v "${PWD}/certbot:/etc/letsencrypt" -v "${PWD}/certbot/www:/var/www/certbot" certbot/certbot certonly -n --webroot --agree-tos --email "$EMAIL" --domains "$DOMAIN" --webroot-path /var/www/certbot

# Replace nginx config to serve site through https
cp nginx/TEMPLATE nginx/"$DOMAIN".conf

# Replace template placeholders with actual values
sed -i "s/DOMAIN/$DOMAIN/g" nginx/"$DOMAIN".conf
sed -i "s/CONTAINER/$CONTAINER/g" nginx/"$DOMAIN".conf
sed -i "s/PORT/$PORT/g" nginx/"$DOMAIN".conf

docker-compose restart