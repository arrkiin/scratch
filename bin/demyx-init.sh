#!/bin/zsh
# Demyx
# https://demyx.sh

source /etc/demyx/.config

# Initialize files/directories
demyx-skel

# Set /demyx to read-only
demyx-prod

# Run init scripts when docker.sock is mounted
if [[ -n "$(ls /run | grep docker.sock)" || -n "$DOCKER_HOST" ]]; then
    # Execute update script
    demyx update &

    # Start the API if DEMYX_STACK_SERVER_API has a url defined (Ex: api.domain.tld)
    DEMYX_STACK_SERVER_API="$(demyx info stack --filter=DEMYX_STACK_SERVER_API --quiet)"
    [[ "$DEMYX_STACK_SERVER_API" != false ]] && demyx-api &
fi

# Run sshd
demyx-ssh &

# Final process to run in the foreground
demyx-crond &

tail -f /var/log/demyx/demyx.log
