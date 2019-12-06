#!/bin/sh
# Demyx
# https://demyx.sh
set -eu pipefail

# Set default variables
DEMYX_INSTALL_SKIP_CHECKS=
DEMYX_DOCKER_CHECK="$(which docker)"
DEMYX_SUDO_CHECK="$(id -u)"

if [ "$DEMYX_SUDO_CHECK" != 0 ]; then
    echo -e "\e[31m[CRITICAL]\e[39m Must be ran as root or sudo"
    exit 1
fi

if [ ! -f "$DEMYX_DOCKER_CHECK" ]; then
    echo -e "\e[31m[CRITICAL]\e[39m Docker must be installed"
    exit 1
fi

docker pull demyx/browsersync
docker pull demyx/code-server:wp
docker pull demyx/demyx
docker pull demyx/docker-compose
docker pull demyx/docker-socket-proxy
docker pull demyx/logrotate
docker pull demyx/mariadb:edge
docker pull demyx/nginx
docker pull demyx/ouroboros
docker pull demyx/ssh
docker pull demyx/traefik
docker pull demyx/utilities
docker pull demyx/wordpress
docker pull demyx/wordpress:cli
docker pull phpmyadmin/phpmyadmin

printf "\e[34m[INFO]\e[39m Enter top level domain for Traefik dashboard\n"
read -rp "Domain: " DEMYX_INSTALL_DOMAIN
if [ -z "$DEMYX_INSTALL_DOMAIN" ]; then
    echo -e "\e[31m[CRITICAL]\e[39m Domain cannot be empty"
    exit 1
fi

printf "\e[34m[INFO\e[39m] Lets Encrypt SSL notifications\n"
read -rp "Email: " DEMYX_INSTALL_EMAIL
if [ -z "$DEMYX_INSTALL_EMAIL" ]; then
    echo -e "\e[31m[CRITICAL]\e[39m Email cannot be empty"
    exit 1
fi

printf "\e[34m[INFO]\e[39m Enter username for basic auth\n"
read -rp "Username: " DEMYX_INSTALL_USER
if [ -z "$DEMYX_INSTALL_USER" ]; then
    echo -e "\e[31m[CRITICAL]\e[39m Username cannot be empty"
    exit 1
fi

printf "\e[34m[INFO]\e[39m Enter password for basic auth\n"
read -rp "Password: " DEMYX_INSTALL_PASS
if [ -z "$DEMYX_INSTALL_PASS" ]; then
    echo -e "\e[31m[CRITICAL]\e[39m Password cannot be empty"
    exit 1
fi

printf "\e[34m[INFO\e[39m] Installing demyx chroot\n"
docker run -t --user=root --privileged --rm -v /usr/local/bin:/usr/local/bin demyx/utilities demyx-chroot

demyx --nc

printf "\e[34m[INFO\e[39m] Waiting for demyx container to initialize\n"
sleep 5
demyx cmd install --domain="$DEMYX_INSTALL_DOMAIN" --email="$DEMYX_INSTALL_EMAIL" --user="$DEMYX_INSTALL_USER" --pass="$DEMYX_INSTALL_PASS"

printf "\e[34m[INFO\e[39m] Pinging active server to demyx\n"
docker run -t --rm demyx/utilities curl -s "https://demyx.sh/?action=active&token=V1VpdGNPcWNDVlZSUDFQdFBaR0Zhdz09OjrnA1h6ZbDFJ2T6MHOwg3p4" -o /dev/null

printf "\e[34m[INFO\e[39m] To SSH into the demyx container, paste your keys in /home/demyx/.ssh/authorized_keys inside the demyx container. Then run on the host OS: demyx restart\n"
demyx restart
