# Demyx
# https://demyx.sh
# 
# demyx update
#

demyx_update() {
    if [[ "$DEMYX_TARGET" = show ]]; then
        source "$DEMYX"/.update_local
        source "$DEMYX"/.update_remote
        PRINT_TABLE="DEMYX^ CURRENT^ LATEST\n"
        PRINT_TABLE+="BUILD^ $DEMYX_LOCAL_VERSION^ $([[ "$(echo $DEMYX_LOCAL_VERSION | sed 's|.||g')" -lt "$(echo $DEMYX_REMOTE_VERSION | sed 's|.||g')" ]] && echo "$DEMYX_REMOTE_VERSION")\n"
        PRINT_TABLE+="BROWSERSYNC^ $DEMYX_LOCAL_BROWSERSYNC_VERSION^ $([[ "$DEMYX_LOCAL_BROWSERSYNC_VERSION" != "$DEMYX_REMOTE_BROWSERSYNC_VERSION" ]] && echo "$DEMYX_REMOTE_BROWSERSYNC_VERSION")\n"
        PRINT_TABLE+="CODE^ $DEMYX_LOCAL_CODE_VERSION^ $([[ "$DEMYX_LOCAL_CODE_VERSION" != "$DEMYX_REMOTE_CODE_VERSION" ]] && echo "$DEMYX_REMOTE_CODE_VERSION")\n"
        PRINT_TABLE+="DOCKER-COMPOSE^ $DEMYX_LOCAL_DOCKER_COMPOSE_VERSION^ $([[ "$DEMYX_LOCAL_DOCKER_COMPOSE_VERSION" != "$DEMYX_REMOTE_DOCKER_COMPOSE_VERSION" ]] && echo "$DEMYX_REMOTE_DOCKER_COMPOSE_VERSION")\n"
        PRINT_TABLE+="DOCKER-SOCKET-PROXY^ $DEMYX_LOCAL_HAPROXY_VERSION^ $([[ "$DEMYX_LOCAL_HAPROXY_VERSION" != "$DEMYX_REMOTE_HAPROXY_VERSION" ]] && echo "$DEMYX_REMOTE_HAPROXY_VERSION")\n"
        PRINT_TABLE+="LOGROTATE^ $DEMYX_LOCAL_LOGROTATE_VERSION^ $([[ "$DEMYX_LOCAL_LOGROTATE_VERSION" != "$DEMYX_REMOTE_LOGROTATE_VERSION" ]] && echo "$DEMYX_REMOTE_LOGROTATE_VERSION")\n"
        PRINT_TABLE+="MARIADB^ $DEMYX_LOCAL_MARIADB_VERSION^ $([[ "$DEMYX_LOCAL_MARIADB_VERSION" != "$DEMYX_REMOTE_MARIADB_VERSION" ]] && echo "$DEMYX_REMOTE_MARIADB_VERSION")\n"
        PRINT_TABLE+="NGINX^ $DEMYX_LOCAL_NGINX_VERSION^ $([[ "$DEMYX_LOCAL_NGINX_VERSION" != "$DEMYX_REMOTE_NGINX_VERSION" ]] && echo "$DEMYX_REMOTE_NGINX_VERSION")\n"
        PRINT_TABLE+="OPENLITESPEED^ $DEMYX_LOCAL_OPENLITESPEED_VERSION^ $([[ "$DEMYX_LOCAL_OPENLITESPEED_VERSION" != "$DEMYX_REMOTE_OPENLITESPEED_VERSION" ]] && echo "$DEMYX_REMOTE_OPENLITESPEED_VERSION")\n"
        PRINT_TABLE+="OPENLITESPEED-LSPHP^ $DEMYX_LOCAL_OPENLITESPEED_LSPHP_VERSION^ $([[ "$DEMYX_LOCAL_OPENLITESPEED_LSPHP_VERSION" != "$DEMYX_REMOTE_OPENLITESPEED_LSPHP_VERSION" ]] && echo "$DEMYX_REMOTE_OPENLITESPEED_LSPHP_VERSION")\n"
        PRINT_TABLE+="SSH^ $DEMYX_LOCAL_OPENSSH_VERSION^ $([[ "$DEMYX_LOCAL_OPENSSH_VERSION" != "$DEMYX_REMOTE_OPENSSH_VERSION" ]] && echo "$DEMYX_REMOTE_OPENSSH_VERSION")\n"
        PRINT_TABLE+="TRAEFIK^ $DEMYX_LOCAL_TRAEFIK_VERSION^ $([[ "$DEMYX_LOCAL_TRAEFIK_VERSION" != "$DEMYX_REMOTE_TRAEFIK_VERSION" ]] && echo "$DEMYX_REMOTE_TRAEFIK_VERSION")\n"
        PRINT_TABLE+="UTILITIES^ $DEMYX_LOCAL_UTILITIES_VERSION^ $([[ "$DEMYX_LOCAL_UTILITIES_VERSION" != "$DEMYX_REMOTE_UTILITIES_VERSION" ]] && echo "$DEMYX_REMOTE_UTILITIES_VERSION")\n"
        PRINT_TABLE+="WORDPRESS^ $DEMYX_LOCAL_WORDPRESS_VERSION^ $([[ "$DEMYX_LOCAL_WORDPRESS_VERSION" != "$DEMYX_REMOTE_WORDPRESS_VERSION" ]] && echo "$DEMYX_REMOTE_WORDPRESS_VERSION")\n"
        PRINT_TABLE+="WORDPRESS-CLI^ $DEMYX_LOCAL_WORDPRESS_CLI_VERSION^ $([[ "$DEMYX_LOCAL_WORDPRESS_CLI_VERSION" != "$DEMYX_REMOTE_WORDPRESS_CLI_VERSION" ]] && echo "$DEMYX_REMOTE_WORDPRESS_CLI_VERSION")\n"
        PRINT_TABLE+="WORDPRESS-PHP^ $DEMYX_LOCAL_WORDPRESS_PHP_VERSION^ $([[ "$DEMYX_LOCAL_WORDPRESS_PHP_VERSION" != "$DEMYX_REMOTE_WORDPRESS_PHP_VERSION" ]] && echo "$DEMYX_REMOTE_WORDPRESS_PHP_VERSION")\n"
        PRINT_TABLE+="WORDPRESS-BEDROCK^ $DEMYX_LOCAL_WORDPRESS_BEDROCK_VERSION^ $([[ "$DEMYX_LOCAL_WORDPRESS_BEDROCK_VERSION" != "$DEMYX_REMOTE_WORDPRESS_BEDROCK_VERSION" ]] && echo "$DEMYX_REMOTE_WORDPRESS_BEDROCK_VERSION")"
        demyx_execute -v demyx_table "$PRINT_TABLE"
    else
        # Build local versions
        if [[ ! -f "$DEMYX"/.update_local ]]; then
            demyx_echo "Updating local cache"
            demyx_execute demyx_update_local
        fi

        # Build remote versions
        if [[ ! -f "$DEMYX"/.update_remote ]]; then
            demyx_echo "Updating remote cache"
            demyx_execute demyx_update_remote
        fi

        # Get images that needs updating
        if [[ ! -f "$DEMYX"/.update_image ]]; then
            demyx_echo "Updating image cache"
            demyx_execute demyx_update_image
        fi

        # Update chroot on the host
        demyx_echo "Updating demyx helper on the host"
        demyx_execute docker run -t --rm \
            -v /usr/local/bin:/tmp \
            --user=root \
            --privileged \
            --entrypoint=bash \
            demyx/demyx -c 'cp -f /etc/demyx/host.sh /tmp/demyx; chmod +x /tmp/demyx'
    fi
}
