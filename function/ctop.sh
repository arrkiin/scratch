# Demyx
# https://demyx.sh
# 
# demyx ctop
#
demyx_ctop() {
    while :; do
        case "$1" in
            -f|--force)
                DEMYX_CTOP_FORCE=1
                ;;
            --)
                shift
                break
                ;;
            -?*)
                printf '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$1" >&2
                exit 1
                ;;
            *)
                break
        esac
        shift
    done
    DEMYX_CTOP_CHECK=$(docker ps | grep quay.io/vektorlab/ctop || true)

    if [[ "$DEMYX_CTOP_FORCE" ]]; then
        if [[ -n "$DEMYX_CTOP_CHECK" ]]; then
            demyx_echo 'Restarting ctop'
            demyx_execute docker stop demyx_ctop
        fi
        demyx_execute -v docker run -it --rm --name demyx_ctop -v /var/run/docker.sock:/var/run/docker.sock:ro quay.io/vektorlab/ctop
    elif [[ -n "$DEMYX_CTOP_CHECK" ]]; then
        demyx_execute -v docker exec -it demyx_ctop /ctop
    else
        demyx_execute -v docker run -it --rm --name demyx_ctop -v /var/run/docker.sock:/var/run/docker.sock:ro quay.io/vektorlab/ctop
    fi
}
