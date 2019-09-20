# coder
[![Build Status](https://img.shields.io/travis/demyxco/coder?style=flat)](https://travis-ci.org/demyxco/coder)
[![Docker Pulls](https://img.shields.io/docker/pulls/demyx/coder?style=flat&color=blue)](https://hub.docker.com/r/demyx/coder)
[![Architecture](https://img.shields.io/badge/linux-amd64-important?style=flat&color=blue)](https://hub.docker.com/r/demyx/coder)
[![Ubuntu](https://img.shields.io/badge/ubuntu-18.04-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/coder)
[![code-server](https://img.shields.io/badge/code--server-2.1523--vsc1.38.1-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/coder)
[![Buy Me A Coffee](https://img.shields.io/badge/buy_me_coffee-$5-informational?style=flat&color=blue)](https://www.buymeacoffee.com/VXqkQK5tb)

code-server is VS Code running on a remote server, accessible through the browser.

DEMYX | LATEST | WP
--- | --- | ---
TAG | latest | wp
USER<br />GROUP | coder (1000)<br />coder (1000)  | www-data (82)<br />www-data (82)
WORKDIR | /home/coder | /var/www/html
PORT | 8080 | 8080 3000
DEFAULT PASSWORD | demyx | demyx
TIMEZONE | America/Los_Angeles | America/Los_Angeles
SHELL | zsh | zsh
SHELL THEME | Oh My Zsh "yg" | Oh My Zsh "yg"
PACKAGES | zsh jq htop nano tzdata | zsh jq htop nano tzdata composer nvm npm browser-sync wp-cli

## Updates
[![Code Size](https://img.shields.io/github/languages/code-size/demyxco/coder?style=flat&color=blue)](https://github.com/demyxco/coder)
[![Repository Size](https://img.shields.io/github/repo-size/demyxco/coder?style=flat&color=blue)](https://github.com/demyxco/coder)
[![Watches](https://img.shields.io/github/watchers/demyxco/coder?style=flat&color=blue)](https://github.com/demyxco/coder)
[![Stars](https://img.shields.io/github/stars/demyxco/coder?style=flat&color=blue)](https://github.com/demyxco/coder)
[![Forks](https://img.shields.io/github/forks/demyxco/coder?style=flat&color=blue)](https://github.com/demyxco/coder)

* Auto built weekly on Sundays (America/Los_Angeles)
* Rolling release updates

## Environment Variables

To disable password authentication, set CODER_AUTH to false.

DEMYX | LATEST | WP
--- | --- | ---
CODER_AUTH | true | true
PASSWORD | demyx | demyx
TZ | America/Los_Angeles | America/Los_Angeles

## Usage
This config requires no .toml for Traefik and is ready to go when running: 
`docker-compose up -d`. 

SSL/TLS
* Remove the comments (#)
* `docker run -t --rm -v demyx_traefik:/demyx demyx/utilities "touch /demyx/acme.json; chmod 600 /demyx/acme.json"`

```
version: "3.7"

services:
  traefik:
    image: traefik:v1.7.16
    container_name: demyx_traefik
    restart: unless-stopped
    command: 
      - --api
      - --api.statistics.recenterrors=100
      - --docker
      - --docker.watch=true
      - --docker.exposedbydefault=false
      - "--entrypoints=Name:http Address::80"
      #- "--entrypoints=Name:https Address::443 TLS"
      - --defaultentrypoints=http
      #- --defaultentrypoints=http,https
      #- --acme
      #- --acme.email=info@domain.tld
      #- --acme.storage=/demyx/acme.json
      #- --acme.entrypoint=https
      #- --acme.onhostrule=true
      #- --acme.httpchallenge.entrypoint=http
      - --logLevel=INFO
      - --accessLog.filePath=/demyx/access.log
      - --traefikLog.filePath=/demyx/traefik.log
    networks:
      - demyx
    ports:
      - 80:80
      #- 443:443
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      #- demyx_traefik:/demyx/acme.json
    labels:
      - "traefik.enable=true"
      - "traefik.port=8080"
      - "traefik.frontend.rule=Host:traefik.domain.tld"
      #- "traefik.frontend.redirect.entryPoint=https"
      #- "traefik.frontend.auth.basic.users=${DEMYX_STACK_AUTH}"
      #- "traefik.frontend.headers.forceSTSHeader=true"
      #- "traefik.frontend.headers.STSSeconds=315360000"
      #- "traefik.frontend.headers.STSIncludeSubdomains=true"
      #- "traefik.frontend.headers.STSPreload=true"  
  code_server:
    container_name: demyx_cs
    image: demyx/code-server
    restart: unless-stopped
    networks:
      - demyx
    volumes:
      - demyx_cs:/home/coder
    environment:
      CODER_AUTH: true
      PASSWORD: demyx
      TZ: America/Los_Angeles
    labels:
      - "traefik.enable=true"
      - "traefik.port=8080"
      - "traefik.frontend.rule=Host:domain.tld"
      #- "traefik.frontend.redirect.entryPoint=https"
      #- "traefik.frontend.headers.forceSTSHeader=true"
      #- "traefik.frontend.headers.STSSeconds=315360000"
      #- "traefik.frontend.headers.STSIncludeSubdomains=true"
      #- "traefik.frontend.headers.STSPreload=true"
volumes:
  demyx_cs:
    name: demyx_cs
  demyx_traefik:
    name: demyx_traefik
networks:
  demyx:
    name: demyx
```

## Support

* [#demyx](https://webchat.freenode.net/?channel=#demyx)
