# Demyx
# https://demyx.sh
# 
# demyx stack <docker-compose args>
#
demyx_stack() {
    while :; do
        case "$2" in
            ouroboros)
                DEMYX_STACK_SELECT=ouroboros
                ;;
            refresh)
                DEMYX_STACK_SELECT=refresh
                ;;
            upgrade)
                DEMYX_STACK_SELECT=upgrade
                ;;
            --auto-update|--auto-update=on)
                DEMYX_STACK_AUTO_UPDATE=on
                ;;
            --auto-update=off)
                DEMYX_STACK_AUTO_UPDATE=off
                ;;
            --cloudflare|--cloudflare=on)
                DEMYX_STACK_CLOUDFLARE=on
                ;;
            --cloudflare=off)
                DEMYX_STACK_CLOUDFLARE=off
                ;;
            --cf-api-email=?*)
                DEMYX_STACK_CLOUDFLARE_API_EMAIL=${2#*=}
                ;;
            --cf-api-email=)
                demyx_die '"--cf-api-email" cannot be empty'
                ;;
            --cf-api-key=?*)
                DEMYX_STACK_CLOUDFLARE_API_KEY=${2#*=}
                ;;
            --cf-api-key=)
                demyx_die '"--cf-api-key" cannot be empty'
                ;;
            --healthcheck|--healthcheck=on)
                DEMYX_STACK_HEALTHCHECK=on
                ;;
            --healthcheck=off)
                DEMYX_STACK_HEALTHCHECK=off
                ;;
            --ignore=?*)
                DEMYX_STACK_IGNORE=${2#*=}
                ;;
            --ignore=)
                demyx_die '"--ignore" cannot be empty'
                ;;
            --monitor|--monitor=on)
                DEMYX_STACK_MONITOR=on
                ;;
            --monitor=off)
                DEMYX_STACK_MONITOR=off
                ;;
            --tracker|--tracker=on)
                DEMYX_STACK_TRACKER=on
                ;;
            --tracker=off)
                DEMYX_STACK_TRACKER=off
                ;;
            --)
                shift
                break
                ;;
            -?*)
                printf '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$2" >&2
                exit 1
                ;;
            *)
                break
        esac
        shift
    done

    if [[ "$DEMYX_STACK_SELECT" = ouroboros ]]; then
        [[ -z "$DEMYX_STACK_IGNORE" ]] && demyx_die 'You need to specificy the ignore flag: --ignore'

        DEMYX_STACK_OUROBOROS_IGNORE_CHECK=$(grep DEMYX_STACK_OUROBOROS_IGNORE "$DEMYX_STACK"/.env)
        
        # Regenerate stack's configs if the check returns null
        if [[ -z "$DEMYX_STACK_OUROBOROS_IGNORE_CHECK" ]]; then
            demyx stack refresh
        fi

        if [[ "$DEMYX_STACK_IGNORE" = off ]]; then
            demyx_echo 'Updating Ouroboros'
            demyx_execute sed -i "s|DEMYX_STACK_OUROBOROS_IGNORE=.*|DEMYX_STACK_OUROBOROS_IGNORE=|g" "$DEMYX_STACK"/.env
        else
            demyx_echo 'Updating Ouroboros'
            demyx_execute sed -i "s|DEMYX_STACK_OUROBOROS_IGNORE=.*|DEMYX_STACK_OUROBOROS_IGNORE=\"$DEMYX_STACK_IGNORE\"|g" "$DEMYX_STACK"/.env
        fi

        demyx compose stack up -d
    elif [[ "$DEMYX_STACK_SELECT" = refresh ]]; then
        demyx_echo 'Backing up stack directory as /demyx/backup/stack.tgz'
        demyx_execute tar -czf /demyx/backup/stack.tgz -C /demyx/app stack

        source "$DEMYX_FUNCTION"/env.sh
        source "$DEMYX_FUNCTION"/yml.sh

        demyx_echo 'Refreshing stack env and yml'

        # Traefik backwards compatibility
        if [[ "$DEMYX_CHECK_TRAEFIK" = 1 ]]; then
            demyx_execute demyx_stack_env; demyx_stack_yml
        else
            demyx_execute demyx_stack_v2_env; demyx_stack_v2_yml
        fi

        demyx compose stack up -d --remove-orphans
    elif [[ "$DEMYX_STACK_SELECT" = upgrade ]]; then
        if [[ "$DEMYX_CHECK_TRAEFIK" = 1 ]]; then
            echo -en "\e[33m"
            read -rep "[WARNING] Upgrading the stack will stop all network activity. Update all configs? [yY]: " DEMYX_STACK_UPGRADE_CONFIRM
            echo -en "\e[39m"
            
            [[ "$DEMYX_STACK_UPGRADE_CONFIRM" != [yY] ]] && demyx_die 'Cancel upgrading'
            
            demyx_echo 'Starting stack upgrade container'
            demyx_execute docker run -dit --rm --name demyx_upgrade demyx/utilities sh

            demyx_echo 'Downloading and extracting Traefik Migration Tool'
            demyx_execute wget https://github.com/containous/traefik-migration-tool/releases/download/v0.8.0/traefik-migration-tool_v0.8.0_linux_amd64.tar.gz -qO /tmp/traefik-migration-tool_v0.8.0_linux_amd64.tar.gz; \
                tar -xzf /tmp/traefik-migration-tool_v0.8.0_linux_amd64.tar.gz -C /tmp

            demyx_echo 'Upgrading acme.json'
            demyx_execute docker cp demyx_traefik:/demyx/acme.json /tmp; \
                docker cp /tmp/traefik-migration-tool demyx_upgrade:/; \
                docker cp /tmp/acme.json demyx_upgrade:/; \
                docker exec -t demyx_upgrade sh -c "/traefik-migration-tool acme --input=/acme.json --output=/acme.json --resolver=demyx"; \
                docker cp demyx_upgrade:/acme.json /tmp; \
                docker cp /tmp/acme.json demyx_traefik:/demyx

            demyx_echo 'Stopping stack upgrade container'
            demyx_execute docker stop demyx_upgrade

            demyx_echo 'Updating Traefik'
            demyx_execute sed -i "s|traefik:v1.7.16|traefik|g" "$DEMYX_STACK"/docker-compose.yml; \
                docker pull traefik:latest

            demyx stack refresh
            demyx config all --refresh

            demyx_execute -v echo -e "\e[32m[SUCCESS]\e[39m Upgrade has finished, you will need to update the docker-compose labels for non Demyx apps."
        else
            demyx_die 'The stack is already updated.'
        fi
    elif [[ "$DEMYX_STACK_AUTO_UPDATE" = on ]]; then
        demyx_echo 'Turn on stack auto update'
        demyx_execute sed -i 's/DEMYX_STACK_AUTO_UPDATE=off/DEMYX_STACK_AUTO_UPDATE=on/g' "$DEMYX_STACK"/.env
    elif [[ "$DEMYX_STACK_AUTO_UPDATE" = off ]]; then
        demyx_echo 'Turn off stack auto update'
        demyx_execute sed -i 's/DEMYX_STACK_AUTO_UPDATE=on/DEMYX_STACK_AUTO_UPDATE=off/g' "$DEMYX_STACK"/.env
    elif [[ "$DEMYX_STACK_CLOUDFLARE" = on ]]; then
        [[ -z "$DEMYX_STACK_CLOUDFLARE_API_EMAIL" ]] && demyx_die '--cf-api-email is missing'
        [[ -z "$DEMYX_STACK_CLOUDFLARE_API_KEY" ]] && demyx_die '--cf-api-key is missing'

        source "$DEMYX_FUNCTION"/env.sh
        source "$DEMYX_FUNCTION"/yml.sh

        demyx_echo 'Enabling Cloudflare as the certificate resolver'
        demyx_execute demyx_stack_v2_env; \
            sed -i "s|DEMYX_STACK_CLOUDFLARE=.*|DEMYX_STACK_CLOUDFLARE=on|g" "$DEMYX_STACK"/.env; \
            sed -i "s|DEMYX_STACK_CLOUDFLARE_EMAIL=.*|DEMYX_STACK_CLOUDFLARE_EMAIL=$DEMYX_STACK_CLOUDFLARE_API_EMAIL|g" "$DEMYX_STACK"/.env; \
            sed -i "s|DEMYX_STACK_CLOUDFLARE_KEY=.*|DEMYX_STACK_CLOUDFLARE_KEY=$DEMYX_STACK_CLOUDFLARE_API_KEY|g" "$DEMYX_STACK"/.env; \
            demyx_stack_v2_yml

        demyx compose stack up -d
    elif [[ "$DEMYX_STACK_CLOUDFLARE" = off ]]; then
        demyx_echo 'Disabling Cloudflare as the certificate resolver, switching back to HTTP'
        demyx_execute sed -i "s|DEMYX_STACK_CLOUDFLARE=.*|DEMYX_STACK_CLOUDFLARE=off|g" "$DEMYX_STACK"/.env

        demyx compose stack up -d
    elif [[ "$DEMYX_STACK_HEALTHCHECK" = on ]]; then
        demyx_echo 'Turn on stack healthcheck'
        demyx_execute sed -i 's/DEMYX_STACK_HEALTHCHECK=off/DEMYX_STACK_HEALTHCHECK=on/g' "$DEMYX_STACK"/.env
    elif [[ "$DEMYX_STACK_HEALTHCHECK" = off ]]; then
        demyx_echo 'Turn off stack healthcheck'
        demyx_execute sed -i 's/DEMYX_STACK_HEALTHCHECK=on/DEMYX_STACK_HEALTHCHECK=off/g' "$DEMYX_STACK"/.env
    elif [[ "$DEMYX_STACK_MONITOR" = on ]]; then
        demyx_echo 'Turn on stack monitor'
        demyx_execute sed -i 's/DEMYX_STACK_MONITOR=off/DEMYX_STACK_MONITOR=on/g' "$DEMYX_STACK"/.env
    elif [[ "$DEMYX_STACK_MONITOR" = off ]]; then
        demyx_echo 'Turn off stack monitor'
        demyx_execute sed -i 's/DEMYX_STACK_MONITOR=on/DEMYX_STACK_MONITOR=off/g' "$DEMYX_STACK"/.env
    elif [[ "$DEMYX_STACK_TRACKER" = on ]]; then
        demyx_echo 'Turn on stack tracker'
        demyx_execute sed -i 's/DEMYX_STACK_TRACKER=off/DEMYX_STACK_TRACKER=on/g' "$DEMYX_STACK"/.env
    elif [[ "$DEMYX_STACK_TRACKER" = off ]]; then
        demyx_echo 'Turn off stack tracker'
        demyx_execute sed -i 's/DEMYX_STACK_TRACKER=on/DEMYX_STACK_TRACKER=off/g' "$DEMYX_STACK"/.env
    else
        demyx_die --command-not-found
    fi
}
