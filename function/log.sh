# Demyx
# https://demyx.sh
# 
# demyx log <app> <args>
#
demyx_log() {
    while :; do
        case "$3" in
            -e|--error)
                DEMYX_LOG_ERROR=1
                ;;
            -f|--follow)
                DEMYX_LOG_FOLLOW=-f
                ;;
            --rotate)
                DEMYX_LOG_ROTATE=1
                ;;
            --)
                shift
                break
                ;;
            -?*)
                printf '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$3" >&2
                exit 1
                ;;
            *) 
                break
        esac
        shift
    done

    demyx_app_config
    demyx_app_is_up

    if [[ "$DEMYX_TARGET" = api ]]; then
        tail "$DEMYX_LOG_FOLLOW" /var/log/demyx/api.log
    elif [[ "$DEMYX_TARGET" = cron ]]; then
        tail "$DEMYX_LOG_FOLLOW" /var/log/demyx/cron.log
    elif [[ "$DEMYX_TARGET" = main ]]; then
        if [[ -n "$DEMYX_LOG_ROTATE" ]]; then
            demyx_echo 'Rotating demyx log'
            demyx_execute docker run -t --rm -e DEMYX_LOG=/var/log/demyx --volumes-from demyx demyx/logrotate
        else
            if [[ -n "$DEMYX_LOG_ERROR" ]]; then
                tail /var/log/demyx/demyx.log $DEMYX_LOG_FOLLOW
            else
                docker logs $DEMYX_LOG_FOLLOW demyx
            fi
        fi
    elif [[ "$DEMYX_TARGET" = ouroboros ]]; then
        docker logs demyx_ouroboros "$DEMYX_LOG_FOLLOW"
    elif [[ "$DEMYX_TARGET" = traefik ]]; then
        if [[ -n "$DEMYX_LOG_ERROR" ]]; then
            tail "$DEMYX_LOG_FOLLOW" /var/log/demyx/traefik.error.log
        else
            tail "$DEMYX_LOG_FOLLOW" /var/log/demyx/traefik.access.log
        fi
    elif [[ "$DEMYX_APP_TYPE" = wp ]]; then
        if [[ -n "$DEMYX_LOG_ROTATE" ]]; then
            demyx_echo "Rotating $DEMYX_APP_DOMAIN log"
            demyx_execute docker run -t --rm -e DEMYX_LOG=/var/log/demyx --volumes-from "$DEMYX_APP_WP_CONTAINER" demyx/logrotate
        else
            DEMYX_LOG_WP=access
            [[ -n "$DEMYX_LOG_ERROR" ]] && DEMYX_LOG_WP=error
            docker exec -it "$DEMYX_APP_WP_CONTAINER" tail $DEMYX_LOG_FOLLOW /var/log/demyx/"$DEMYX_APP_DOMAIN"."$DEMYX_LOG_WP".log
        fi
    fi
}
