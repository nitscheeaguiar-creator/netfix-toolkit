#!/usr/bin/env bash

DESTINATION="/usr/local/bin/netfix"

if [ "$EUID" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        exec sudo "$0" "$@"
    else
        echo "[FAIL] Execute como root ou instale o sudo"
        exit 1
    fi
fi

if [ ! -f "$DESTINATION" ]; then
    echo "[INFO] NetFix não está instalado"
    exit 0
fi

rm "$DESTINATION"

echo "[OK] NetFix removido de $DESTINATION"
