#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

export AUTH_SECRET="$(jq -r '.auth_secret // empty' "$CONFIG_PATH")"
export APP_BASE_URL="$(jq -r '.app_base_url // empty' "$CONFIG_PATH")"
export TRUST_PROXY="$(jq -r '.trust_proxy // true' "$CONFIG_PATH")"

if [ -z "$AUTH_SECRET" ] || [ "${#AUTH_SECRET}" -lt 32 ]; then
  echo "[papra-addon] FEHLER: 'auth_secret' muss in den Add-on-Optionen gesetzt sein (mindestens 32 Zeichen)."
  echo "[papra-addon] Erzeuge z.B. mit: openssl rand -base64 32"
  exit 1
fi

if [ -z "$APP_BASE_URL" ]; then
  echo "[papra-addon] FEHLER: 'app_base_url' muss in den Add-on-Optionen gesetzt sein."
  echo "[papra-addon] Das muss GENAU die URL sein, die du im Browser eingibst, inkl. Protokoll und Port,"
  echo "[papra-addon] z.B. http://192.168.1.50:1221 oder https://papra.deine-domain.de"
  echo "[papra-addon] Ohne abschliessenden Schraegstrich, sonst schlaegt die Origin-Pruefung von Papra fehl."
  exit 1
fi

# Papra erwartet seine Daten standardmaessig unter /app/app-data.
# Wir verlinken das auf den persistenten HA-Add-on-Datenordner /data,
# damit Dokumente Neustarts und Updates ueberleben.
mkdir -p /data/app-data
rm -rf /app/app-data
ln -s /data/app-data /app/app-data

echo "[papra-addon] Starte Papra auf Port 1221 (APP_BASE_URL=$APP_BASE_URL) ..."

if [ "$#" -eq 0 ]; then
  echo "[papra-addon] FEHLER: Kein Startbefehl (CMD) uebergeben - das sollte nie passieren."
  echo "[papra-addon] Pruefe, ob im Dockerfile sowohl ENTRYPOINT als auch CMD gesetzt sind."
  exit 1
fi

echo "[papra-addon] Befehl: $*"
exec "$@"
