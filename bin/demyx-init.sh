#!/bin/bash
# Demyx
# https://demyx.sh

source /etc/demyx/.config

# Initialize files/directories
demyx-skel

# Run init scripts when docker.sock is mounted
if [[ -n "$(ls /run | grep docker.sock)" ]]; then
    # Execute update script
    demyx update &

    # Start the API if DEMYX_STACK_SERVER_API has a url defined (Ex: api.domain.tld)
    DEMYX_STACK_SERVER_API="$(demyx info stack --filter=DEMYX_STACK_SERVER_API --quiet)"
    [[ "$DEMYX_STACK_SERVER_API" != false ]] && demyx-api &
fi

# Run sshd
demyx-ssh &

# Set /demyx to read-only
demyx-prod

# Final process to run in the foreground
demyx-crond
