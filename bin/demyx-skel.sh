#!/bin/bash
# Demyx
# https://demyx.sh

source /etc/demyx/.config

# Initialize files/directories
if [[ -z "$(ls -A "$DEMYX")" ]]; then
    echo "[demyx] initialize files/directories..."
    mkdir -p "$DEMYX_APP"/html
    mkdir -p "$DEMYX_APP"/php
    mkdir -p "$DEMYX_APP"/wp
    mkdir -p "$DEMYX_APP"/stack
    mkdir -p "$DEMYX_BACKUP"
    mkdir -p "$DEMYX"/custom
    cp "$DEMYX_ETC"/example/example-callback.sh "$DEMYX"/custom
    chown -R demyx:demyx "$DEMYX"
fi
