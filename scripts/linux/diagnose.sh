#!/usr/bin/env bash

FAILURES=0

if [ "$#" -gt 1 ]; then
    echo "[FAIL] Informe apenas um destino"
    echo "Uso: netfix <domínio|IP|URL>"
    exit 2
fi

if [ "$#" -eq 0 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "NetFix Toolkit - Diagnóstico de rede"
    echo
    echo "Uso:"
    echo "  netfix <domínio>"
    echo "  netfix <IP>"
    echo "  netfix <URL>"
    echo
    echo "Exemplos:"
    echo "  netfix example.com"
    echo "  netfix 192.168.0.1"
    echo "  netfix https://example.com"
    exit 0
fi

INPUT="$1"
HTTP_TARGET="$INPUT"
PROTOCOL="https"
TCP_PORT=443
HAS_SCHEME=0
IS_IP=0

if [[ "$INPUT" == *"://"* ]]; then
    HAS_SCHEME=1
    PROTOCOL="${INPUT%%://*}"
    HTTP_TARGET="$INPUT"

    if [[ "$PROTOCOL" != "http" && "$PROTOCOL" != "https" ]]; then
        echo "[FAIL] Protocolo não suportado: $PROTOCOL"
        echo "Utilize http:// ou https://"
        exit 2
    fi
else
    HTTP_TARGET="https://$INPUT"

    if [[ "$INPUT" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        IS_IP=1
    fi
fi

AUTHORITY="${HTTP_TARGET#*://}"
AUTHORITY="${AUTHORITY%%/*}"
AUTHORITY="${AUTHORITY%%\?*}"
AUTHORITY="${AUTHORITY%%\#*}"
AUTHORITY="${AUTHORITY##*@}"

TCP_TARGET="$AUTHORITY"

if [[ "$AUTHORITY" == *":"* ]]; then
    TCP_TARGET="${AUTHORITY%:*}"
    TCP_PORT="${AUTHORITY##*:}"
else
    if [ "$PROTOCOL" = "http" ]; then
        TCP_PORT=80
    fi
fi

if [ -z "$TCP_TARGET" ]; then
    echo "[FAIL] Destino inválido"
    exit 2
fi

if ! [[ "$TCP_PORT" =~ ^[0-9]+$ ]] || [ "$TCP_PORT" -lt 1 ] || [ "$TCP_PORT" -gt 65535 ]; then
    echo "[FAIL] Porta inválida: $TCP_PORT"
    exit 2
fi

echo "Destino informado: $INPUT"
echo "Host identificado: $TCP_TARGET"
echo "Protocolo: $PROTOCOL"
echo "Porta TCP: $TCP_PORT"
echo

GATEWAY=$(ip route show default | awk 'NR==1 {print $3}')

if [ -z "$GATEWAY" ]; then
    echo "[FAIL] Nenhum gateway padrão encontrado"
    FAILURES=$((FAILURES + 1))
else
    echo "Gateway identificado: $GATEWAY"

    if ping -c 1 -W 2 "$GATEWAY" >/dev/null 2>&1; then
        echo "[OK] Gateway acessível"
    else
        echo "[FAIL] Gateway não respondeu"
        FAILURES=$((FAILURES + 1))
    fi
fi

if [ "$IS_IP" -eq 1 ] && [ "$HAS_SCHEME" -eq 0 ]; then
    echo "Modo de diagnóstico: IP direto"

    if ping -c 1 -W 2 "$TCP_TARGET" >/dev/null 2>&1; then
        echo "[OK] IP acessível por ICMP: $TCP_TARGET"
    else
        echo "[FAIL] IP não respondeu ao ping: $TCP_TARGET"
        FAILURES=$((FAILURES + 1))
    fi
else
    DNS_TARGET="$TCP_TARGET"

    if getent ahosts "$DNS_TARGET" >/dev/null 2>&1; then
        echo "[OK] DNS resolveu $DNS_TARGET"
    else
        echo "[FAIL] Falha na resolução DNS"
        FAILURES=$((FAILURES + 1))
    fi

    if nc -z -w 3 "$TCP_TARGET" "$TCP_PORT" >/dev/null 2>&1; then
        echo "[OK] TCP conectado a $TCP_TARGET:$TCP_PORT"
    else
        echo "[FAIL] Falha na conexão TCP com $TCP_TARGET:$TCP_PORT"
        FAILURES=$((FAILURES + 1))
    fi

    if HTTP_STATUS=$(curl -sS -L -o /dev/null -w "%{http_code}" --connect-timeout 5 --max-time 10 "$HTTP_TARGET"); then
        if [[ "$HTTP_STATUS" =~ ^2[0-9][0-9]$ ]]; then
            echo "[OK] HTTP respondeu com status $HTTP_STATUS"
        else
            echo "[FAIL] HTTP respondeu com status $HTTP_STATUS"
            FAILURES=$((FAILURES + 1))
        fi
    else
        echo "[FAIL] Falha na requisição HTTP"
        FAILURES=$((FAILURES + 1))
    fi
fi

echo

if [ "$FAILURES" -eq 0 ]; then
    echo "[OK] Diagnóstico concluído: nenhuma falha encontrada"
    exit 0
else
    echo "[FAIL] Diagnóstico concluído: $FAILURES falha(s) encontrada(s)"
    exit 1
fi
