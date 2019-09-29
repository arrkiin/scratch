# Demyx
# https://demyx.sh

DEMYX_CHECK_SUDO=$(id -u)

if [[ -f "$DEMYX_STACK"/docker-compose.yml ]]; then
    DEMYX_CHECK_TRAEFIK=$(grep -c "traefik:v1.7.16" "$DEMYX_STACK"/docker-compose.yml || true)
fi

if [ "$DEMYX_CHECK_SUDO" != 0 ]; then
    echo -e "\e[31m[CRITICAL]\e[39m Demyx must be ran as sudo"
    exit 1
fi

if [[ ! -d "$DEMYX"/custom/cron ]]; then
    demyx_execute -v cp -r "$DEMYX_ETC"/example/example-cron "$DEMYX"/custom
fi

if [[ "$DEMYX_CHECK_TRAEFIK" = 1 ]]; then
    export DEMYX_CHECK_TRAEFIK=1
else
    export DEMYX_CHECK_TRAEFIK=0
fi