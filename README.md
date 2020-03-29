# Docker Reverse Proxy
This repository contains setup for [Docker](https://www.docker.com/) server to run multiple web applications each having it's own domain and a separate [docker-compose.yml](https://docs.docker.com/compose/) file.
To achieve this [Nginx](https://www.nginx.com/) reverse proxy and [Certbot](https://certbot.eff.org/) are used.

## Installation

- Clone this repository: `git clone https://github.com/MindaugasVarkalys/docker-reverse-proxy.git && cd docker-reverse-proxy`
- Start Nginx Docker container: `sudo docker-compose up -d`
- Add Cronjob to renew SSL certificates: Run `sudo crontab -e` and paste the following line. You should replace `${PWD}` with the absolute path of this repository.
```bash
0 0 * * * docker run -it --rm -v "${PWD}/certbot:/etc/letsencrypt" -v "${PWD}/certbot/www:/var/www/certbot" certbot/certbot renew -n
```

## Adding new project

- Add `reverse_proxy` network to your project's web server container to make it accessible by Nginx reverse proxy.
```yaml
version: '3.7'
services:
  web:
    ...
    networks:
      - reverse_proxy
...
networks:
  reverse_proxy:
    external: true
``` 
- (Re)start your container.
- Run `sudo ./add-site.sh --domain YOUR_DOMAIN --email YOUR_EMAIL --container YOUR_WEB_SERVER_CONTAINER_NAME --port YOUR_WEB_SERVER_EXPOSED_POST` with the real values instead of placeholders.
- Enter URL to the browser. Your site should be working!

## add-site.sh  

When run, this command does the following things:

- Copies Nginx configuration from [nginx/TEMPLATE_CERTBOT](/nginx/TEMPLATE_CERTBOT) file to host specified domain without SSL. This is required, so Certbot can access and verify the domain before issuing a certificate.
- Gets a certificate using Certbot Docker image.
- Replaces Nginx configuration with [nginx/TEMPLATE](/nginx/TEMPLATE) to run the site with SSL.

Command has the following options:
- `--domain, -d` (required) - Domain where you want to host your site.
- `--email, -e` (required) - Your email. Email is required by Certbot when issuing a certificate.
- `--port, -p` (optional) - Your web server's container exposed port. Defaults to `80`.
- `--container, -c` (optional) - The name of your project's web server container. Defaults to `DOMAIN_WITHOUT_DOTS + _web_1`. (e.g. if domain is `example.com`, the default container name is `examplecom_web_1`).
This is the same how Docker names your container if you have docker-compose.yml file in the directory named as your domain (e.g. example.com) and your container named `web`.
  