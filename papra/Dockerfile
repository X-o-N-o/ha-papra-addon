# Version wird von der GitHub Action (check-papra-version.yml) automatisch
# hochgezählt, sobald papra-hq/papra ein neues Release veröffentlicht.
ARG PAPRA_VERSION=26.6.0

# "-root" Variante verwenden, damit das Add-on ohne zusätzliche
# Rechteprobleme innerhalb des HA-Containers laufen kann.
FROM ghcr.io/papra-hq/papra:${PAPRA_VERSION}-root

USER root

# jq (zum Lesen der HA-Optionen) und bash nachinstallieren,
# unabhängig davon ob das Basis-Image Alpine oder Debian ist.
RUN set -eux; \
    if command -v apk >/dev/null 2>&1; then \
        apk add --no-cache bash jq; \
    elif command -v apt-get >/dev/null 2>&1; then \
        apt-get update && \
        apt-get install -y --no-install-recommends bash jq && \
        rm -rf /var/lib/apt/lists/*; \
    fi

COPY run.sh /run.sh
RUN chmod a+x /run.sh

# WICHTIG: Ein neues ENTRYPOINT setzt ein von der Basis geerbtes CMD auf
# leer zurueck (Docker-Verhalten). Papras eigener Start-Befehl lautet
# "node dist/index.js" (siehe apps/papra-server/package.json -> "start").
# Ohne dieses explizite CMD wuerde run.sh mit "exec $@" ins Leere laufen
# und der Container wuerde sofort wieder beenden (Start/Stop-Schleife).
ENTRYPOINT ["/run.sh"]
CMD ["node", "dist/index.js"]
