#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/scripts/linux/diagnose.sh"
DESTINATION="/usr/local/bin/netfix"

if [ "$EUID" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        exec sudo "$0" "$@"
    else
        echo "[FAIL] Execute como root ou instale o sudo"
        exit 1
    fi
fi

if [ ! -f "$SOURCE" ]; then
    echo "[FAIL] Script de diagnóstico não encontrado"
    echo "Caminho esperado: $SOURCE"
    exit 1
fi

echo "Instalando NetFix Toolkit..."

install -Dm755 "$SOURCE" "$DESTINATION"

echo "[OK] NetFix instalado em $DESTINATION"
echo "Utilize: netfix example.com"
