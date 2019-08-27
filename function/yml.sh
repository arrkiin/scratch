# Demyx
# https://demyx.sh

demyx_yml() {
    if [[ "$DEMYX_APP_TYPE" = wp ]]; then
        DEMYX_PROTOCOL="- \"traefik.frontend.redirect.entryPoint=http\""
        DEMYX_REGEX_PROTOCOL="https://"
        DEMYX_REGEX_PROTOCOL_REPLACEMENT="http://"

        if [[ "$DEMYX_APP_SSL" = "on" ]]; then
            DEMYX_REGEX_PROTOCOL="http://"
            DEMYX_REGEX_PROTOCOL_REPLACEMENT="https://"
            DEMYX_SERVER_IP=$(demyx util curl -s https://ipecho.net/plain | sed -e 's/\r//g')
            DEMYX_SUBDOMAIN_CHECK=$(demyx util dig +short "$DEMYX_APP_DOMAIN" | sed -e '1d' | sed -e 's/\r//g')
            DEMYX_CLOUDFLARE_CHECK=$(curl -svo /dev/null "$DEMYX_APP_DOMAIN" 2>&1 | grep "Server: cloudflare" || true)
        
            if [[ -n "$DEMYX_SUBDOMAIN_CHECK" ]]; then
                DEMYX_DOMAIN_IP=$DEMYX_SUBDOMAIN_CHECK
            else
                DEMYX_DOMAIN_IP=$(demyx util dig +short "$DEMYX_APP_DOMAIN" | sed -e 's/\r//g')
            fi

            if [[ "$DEMYX_SERVER_IP" = "$DEMYX_DOMAIN_IP" ]] || [[ -n "$DEMYX_CLOUDFLARE_CHECK" ]]; then
                DEMYX_PROTOCOL="- \"traefik.frontend.redirect.entryPoint=https\"
                        - \"traefik.frontend.headers.forceSTSHeader=\${DEMYX_APP_FORCE_STS_HEADER}\"
                        - \"traefik.frontend.headers.STSSeconds=\${DEMYX_APP_STS_SECONDS}\"
                        - \"traefik.frontend.headers.STSIncludeSubdomains=\${DEMYX_APP_STS_INCLUDE_SUBDOMAINS}\"
                        - \"traefik.frontend.headers.STSPreload=\${DEMYX_APP_STS_PRELOAD}\""
            else
                echo -e "\e[33m[WARNING]\e[39m $DEMYX_TARGET does not point to server's IP! Proceeding without SSL..."
                echo "SERVER IP: $DEMYX_SERVER_IP"
                echo "DOMAIN IP: $DEMYX_DOMAIN_IP"
            fi
        fi

        DEMYX_FRONTEND_RULE="- \"traefik.frontend.rule=Host:\${DEMYX_APP_DOMAIN},www.\${DEMYX_APP_DOMAIN}\""
        DEMYX_REGEX="- \"traefik.frontend.redirect.regex=^${DEMYX_REGEX_PROTOCOL}\${DEMYX_APP_DOMAIN}/(.*)\"
                        - \"traefik.frontend.redirect.replacement=${DEMYX_REGEX_PROTOCOL_REPLACEMENT}\${DEMYX_APP_DOMAIN}/\$\$1\""

        if [[ -n "$DEMYX_SUBDOMAIN_CHECK" ]] && [[ -z "$DEMYX_CLOUDFLARE_CHECK" ]]; then
            DEMYX_FRONTEND_RULE="- \"traefik.frontend.rule=Host:\${DEMYX_APP_DOMAIN}\""
        fi
        
        DEMYX_YML_AUTH_CHECK=$(demyx info "$DEMYX_APP_DOMAIN" --filter=DEMYX_APP_AUTH)

        if [[ "$DEMYX_YML_AUTH_CHECK" = on ]]; then
            source "$DEMYX_STACK"/.env
            DEMYX_PARSE_BASIC_AUTH=$(grep -s DEMYX_STACK_AUTH "$DEMYX_STACK"/.env | awk -F '[=]' '{print $2}' | sed 's/\$/$$/g' || true)
            DEMYX_BASIC_AUTH="- \"traefik.bs.frontend.auth.basic.users=${DEMYX_PARSE_BASIC_AUTH}\""
        else
            DEMYX_BASIC_AUTH=
        fi

        cat > "$DEMYX_WP"/"$DEMYX_APP_DOMAIN"/docker-compose.yml <<-EOF
            # AUTO GENERATED
            version: "$DEMYX_DOCKER_COMPOSE"
            services:
                db_${DEMYX_APP_ID}:
                    image: demyx/mariadb
                    restart: unless-stopped
                    networks:
                        - demyx
                    volumes:
                        - wp_${DEMYX_APP_ID}_db:/var/lib/mysql
                    environment:
                        MARIADB_DATABASE: \${WORDPRESS_DB_NAME}
                        MARIADB_USERNAME: \${WORDPRESS_DB_USER}
                        MARIADB_PASSWORD: \${WORDPRESS_DB_PASSWORD}
                        MARIADB_ROOT_PASSWORD: \${MARIADB_ROOT_PASSWORD}
                        MARIADB_DEFAULT_CHARACTER_SET: \${MARIADB_DEFAULT_CHARACTER_SET}
                        MARIADB_CHARACTER_SET_SERVER: \${MARIADB_CHARACTER_SET_SERVER}
                        MARIADB_COLLATION_SERVER: \${MARIADB_COLLATION_SERVER}
                        MARIADB_KEY_BUFFER_SIZE: \${MARIADB_KEY_BUFFER_SIZE}
                        MARIADB_MAX_ALLOWED_PACKET: \${MARIADB_MAX_ALLOWED_PACKET}
                        MARIADB_TABLE_OPEN_CACHE: \${MARIADB_TABLE_OPEN_CACHE}
                        MARIADB_SORT_BUFFER_SIZE: \${MARIADB_SORT_BUFFER_SIZE}
                        MARIADB_NET_BUFFER_SIZE: \${MARIADB_NET_BUFFER_SIZE}
                        MARIADB_READ_BUFFER_SIZE: \${MARIADB_READ_BUFFER_SIZE}
                        MARIADB_READ_RND_BUFFER_SIZE: \${MARIADB_READ_RND_BUFFER_SIZE}
                        MARIADB_MYISAM_SORT_BUFFER_SIZE: \${MARIADB_MYISAM_SORT_BUFFER_SIZE}
                        MARIADB_LOG_BIN: \${MARIADB_LOG_BIN}
                        MARIADB_BINLOG_FORMAT: \${MARIADB_BINLOG_FORMAT}
                        MARIADB_SERVER_ID: \${MARIADB_SERVER_ID}
                        MARIADB_INNODB_DATA_FILE_PATH: \${MARIADB_INNODB_DATA_FILE_PATH}
                        MARIADB_INNODB_BUFFER_POOL_SIZE: \${MARIADB_INNODB_BUFFER_POOL_SIZE}
                        MARIADB_INNODB_LOG_FILE_SIZE: \${MARIADB_INNODB_LOG_FILE_SIZE}
                        MARIADB_INNODB_LOG_BUFFER_SIZE: \${MARIADB_INNODB_LOG_BUFFER_SIZE}
                        MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT: \${MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT}
                        MARIADB_INNODB_LOCK_WAIT_TIMEOUT: \${MARIADB_INNODB_LOCK_WAIT_TIMEOUT}
                        MARIADB_INNODB_USE_NATIVE_AIO: \${MARIADB_INNODB_USE_NATIVE_AIO}
                        MARIADB_MAX_ALLOWED_PACKET: \${MARIADB_MAX_ALLOWED_PACKET}
                        MARIADB_KEY_BUFFER_SIZE: \${MARIADB_KEY_BUFFER_SIZE}
                        MARIADB_SORT_BUFFER_SIZE: \${MARIADB_SORT_BUFFER_SIZE}
                        MARIADB_READ_BUFFER: \${MARIADB_READ_BUFFER}
                        MARIADB_WRITE_BUFFER: \${MARIADB_WRITE_BUFFER}
                        MARIADB_MAX_CONNECTIONS: \${MARIADB_MAX_CONNECTIONS}
                        TZ: America/Los_Angeles
                wp_${DEMYX_APP_ID}:
                    image: demyx/nginx-php-wordpress
                    restart: unless-stopped
                    networks:
                        - demyx
                    environment:
                        WORDPRESS_DB_HOST: \${WORDPRESS_DB_HOST}
                        WORDPRESS_DB_NAME: \${WORDPRESS_DB_NAME}
                        WORDPRESS_DB_USER: \${WORDPRESS_DB_USER}
                        WORDPRESS_DB_PASSWORD: \${WORDPRESS_DB_PASSWORD}
                        TZ: America/Los_Angeles
                    volumes:
                        - wp_${DEMYX_APP_ID}:/var/www/html
                        - wp_${DEMYX_APP_ID}_config:/demyx
                        - wp_${DEMYX_APP_ID}_log:/var/log/demyx
                    labels:
                        - "traefik.enable=true"
                        - "traefik.port=80"
                        $DEMYX_FRONTEND_RULE
                        $DEMYX_REGEX
                        $DEMYX_PROTOCOL
                        $DEMYX_BASIC_AUTH
            volumes:
                wp_${DEMYX_APP_ID}:
                    name: wp_${DEMYX_APP_ID}
                wp_${DEMYX_APP_ID}_db:
                    name: wp_${DEMYX_APP_ID}_db
                wp_${DEMYX_APP_ID}_config:
                    name: wp_${DEMYX_APP_ID}_config
                wp_${DEMYX_APP_ID}_log:
                    name: wp_${DEMYX_APP_ID}_log
            networks:
                demyx:
                    name: demyx
EOF
        # Stupid YAML indentations
        sed -i 's/        //' "$DEMYX_WP"/"$DEMYX_APP_DOMAIN"/docker-compose.yml
        sed -i 's/            /          /' "$DEMYX_WP"/"$DEMYX_APP_DOMAIN"/docker-compose.yml
        sed -i 's/    /  /' "$DEMYX_WP"/"$DEMYX_APP_DOMAIN"/docker-compose.yml
        sed -i 's/      /    /' "$DEMYX_WP"/"$DEMYX_APP_DOMAIN"/docker-compose.yml
        sed -i 's/  //' "$DEMYX_WP"/"$DEMYX_APP_DOMAIN"/docker-compose.yml
        sed -i 's/        /      /' "$DEMYX_WP"/"$DEMYX_APP_DOMAIN"/docker-compose.yml
    fi
}

demyx_stack_yml() {
    if [[ -f "$DEMYX_STACK"/.env ]]; then
        DEMYX_PARSE_BASIC_AUTH=$(grep -s DEMYX_STACK_AUTH "$DEMYX_STACK"/.env | awk -F '[=]' '{print $2}' || true)
        source "$DEMYX_STACK"/.env
        DEMYX_STACK_AUTH="$DEMYX_PARSE_BASIC_AUTH"
    fi
    cat > "$DEMYX_STACK"/docker-compose.yml <<-EOF
        # AUTO GENERATED
        version: "$DEMYX_DOCKER_COMPOSE"
        services:
            traefik:
                image: traefik
                container_name: demyx_traefik
                restart: unless-stopped
                command: 
                    - --api
                    - --api.statistics.recenterrors=\${DEMYX_STACK_RECENT_ERRORS}
                    - --docker
                    - --docker.watch=\${DEMYX_STACK_DOCKER_WATCH}
                    - --docker.exposedbydefault=\${DEMYX_STACK_DOCKER_EXPOSED_BY_DEFAULT}
                    - "--entrypoints=Name:http Address::80"
                    - "--entrypoints=Name:https Address::443 TLS"
                    - --defaultentrypoints=\${DEMYX_STACK_ENTRYPOINT_DEFAULTENTRYPOINTS}
                    - --acme
                    - --acme.email=\${DEMYX_STACK_ACME_EMAIL}
                    - --acme.storage=\${DEMYX_STACK_ACME_STORAGE}
                    - --acme.entrypoint=\${DEMYX_STACK_ACME_ENTRYPOINT}
                    - --acme.onhostrule=\${DEMYX_STACK_ACME_ONHOSTRULE}
                    - --acme.httpchallenge.entrypoint=\${DEMYX_STACK_ACME_HTTPCHALLENGE_ENTRYPOINT}
                    - --logLevel=\${DEMYX_STACK_LOG_LEVEL}
                    - --accessLog.filePath=\${DEMYX_STACK_LOG_ACCESS}
                    - --traefikLog.filePath=\${DEMYX_STACK_LOG_ERROR}
                networks:
                    - demyx
                ports:
                    - 80:80
                    - 443:443
                volumes:
                    - /var/run/docker.sock:/var/run/docker.sock:ro
                    - demyx_traefik:/demyx
                    - demyx_traefik_log:/var/log/demyx
                labels:
                    - "traefik.enable=true"
                    - "traefik.port=8080"
                    - "traefik.frontend.redirect.entryPoint=https"
                    - "traefik.frontend.rule=Host:traefik.\${DEMYX_STACK_DOMAIN}"
                    - "traefik.frontend.auth.basic.users=\${DEMYX_STACK_AUTH}"
                    - "traefik.frontend.headers.forceSTSHeader=\${DEMYX_FORCE_STS_HEADER}"
                    - "traefik.frontend.headers.STSSeconds=\${DEMYX_STS_SECONDS}"
                    - "traefik.frontend.headers.STSIncludeSubdomains=\${DEMYX_STS_INCLUDE_SUBDOMAINS}"
                    - "traefik.frontend.headers.STSPreload=\${DEMYX_STS_PRELOAD}"
            ouroboros:
                container_name: demyx_ouroboros
                image: pyouroboros/ouroboros
                restart: unless-stopped
                networks:
                    - demyx
                environment:
                    SELF_UPDATE: "true"
                    CLEANUP: "true"
                    LATEST: "true"
                    TZ: America/Los_Angeles
                volumes:
                    - /var/run/docker.sock:/var/run/docker.sock:ro
        volumes:
            demyx_traefik:
                name: demyx_traefik
            demyx_traefik_log:
                name: demyx_traefik_log
        networks:
            demyx:
                name: demyx
EOF
    # Stupid YAML indentations
    sed -i 's/      //' "$DEMYX_STACK"/docker-compose.yml
    sed -i 's/            /          /' "$DEMYX_STACK"/docker-compose.yml
    sed -i 's/    /  /' "$DEMYX_STACK"/docker-compose.yml
    sed -i 's/      /    /' "$DEMYX_STACK"/docker-compose.yml
    sed -i 's/  //' "$DEMYX_STACK"/docker-compose.yml
    sed -i 's/        /      /' "$DEMYX_STACK"/docker-compose.yml
}
