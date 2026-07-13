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
# damit Dokumente Neustarts und Updates ueberleben. Das betrifft weiterhin
# immer die Datenbank (db.sqlite) und dient als Fallback fuer Dokumente,
# falls unten kein eigener NAS-Pfad konfiguriert ist.
mkdir -p /data/app-data
rm -rf /app/app-data
ln -s /data/app-data /app/app-data

# --- Dokumentenspeicher auf eigenem NAS/Netzwerkspeicher ------------------
# Optional: Wenn "document_storage_path" gesetzt ist, werden die eigentlichen
# Dokumente NICHT lokal unter /data, sondern unter der HA-Netzwerkfreigabe
# "share" (map: share:rw, liegt im Container unter /share) abgelegt. Diese
# Freigabe muss vorher unter Einstellungen -> System -> Speicher ->
# Netzwerkspeicher als SMB/NFS-Mount deiner NAS (z.B. Synology) eingebunden
# werden (Verwendungszweck: "media" oder "share").
DOCUMENT_STORAGE_PATH="$(jq -r '.document_storage_path // empty' "$CONFIG_PATH")"

if [ -n "$DOCUMENT_STORAGE_PATH" ]; then
  DOC_ROOT="/share/$DOCUMENT_STORAGE_PATH"
  mkdir -p "$DOC_ROOT"
  export DOCUMENT_STORAGE_DRIVER="filesystem"
  export DOCUMENT_STORAGE_FILESYSTEM_ROOT="$DOC_ROOT"
  echo "[papra-addon] Dokumentenspeicher: $DOC_ROOT (auf HA-Netzwerkfreigabe 'share')"
else
  echo "[papra-addon] Dokumentenspeicher: lokal unter /data/app-data/documents"
  echo "[papra-addon] Tipp: Setze die Option 'document_storage_path', um Dokumente"
  echo "[papra-addon] stattdessen auf einer eingebundenen NAS-Freigabe abzulegen."
fi

# --- KI-Funktionen (z.B. automatisches Tagging) ---------------------------
AI_IS_ENABLED="$(jq -r '.ai_is_enabled // false' "$CONFIG_PATH")"
export AI_IS_ENABLED

if [ "$AI_IS_ENABLED" = "true" ]; then
  AI_PROVIDER="$(jq -r '.ai_provider // empty' "$CONFIG_PATH")"
  AI_API_KEY="$(jq -r '.ai_api_key // empty' "$CONFIG_PATH")"
  AI_BASE_URL="$(jq -r '.ai_base_url // empty' "$CONFIG_PATH")"
  AI_DEFAULT_MODEL="$(jq -r '.ai_default_model // empty' "$CONFIG_PATH")"

  # Wenn KI aktiviert, aber kein Provider gewaehlt wurde, "openai" als
  # sinnvollen Standard annehmen (haeufigster Fall, kein Extra-Klick noetig).
  if [ -z "$AI_PROVIDER" ]; then
    AI_PROVIDER="openai"
    echo "[papra-addon] Kein 'ai_provider' gesetzt, verwende Standard: openai"
  fi

  if [ -z "$AI_DEFAULT_MODEL" ]; then
    if [ "$AI_PROVIDER" = "openai" ]; then
      AI_DEFAULT_MODEL="openai://gpt-4o-mini"
      echo "[papra-addon] Kein 'ai_default_model' gesetzt, verwende Standard: $AI_DEFAULT_MODEL"
    else
      echo "[papra-addon] FEHLER: 'ai_is_enabled' ist aktiv, aber 'ai_default_model' ist leer."
      echo "[papra-addon] Format: <adapter>://<model_name>, z.B. openai://gpt-4o-mini"
      exit 1
    fi
  fi

  export AI_DEFAULT_MODEL

  case "$AI_PROVIDER" in
    openai)     KEY_VAR="OPENAI_API_KEY";     URL_VAR="OPENAI_BASE_URL" ;;
    anthropic)  KEY_VAR="ANTHROPIC_API_KEY";  URL_VAR="ANTHROPIC_BASE_URL" ;;
    mistral)    KEY_VAR="MISTRAL_API_KEY";    URL_VAR="MISTRAL_BASE_URL" ;;
    deepseek)   KEY_VAR="DEEPSEEK_API_KEY";   URL_VAR="DEEPSEEK_BASE_URL" ;;
    openrouter) KEY_VAR="OPENROUTER_API_KEY"; URL_VAR="OPENROUTER_BASE_URL" ;;
    cocore)     KEY_VAR="COCORE_API_KEY";     URL_VAR="COCORE_BASE_URL" ;;
    ollama)     KEY_VAR="OLLAMA_API_KEY";     URL_VAR="OLLAMA_BASE_URL" ;;
    lmstudio)   KEY_VAR="LMSTUDIO_API_KEY";   URL_VAR="LMSTUDIO_BASE_URL" ;;
    vllm)       KEY_VAR="VLLM_API_KEY";       URL_VAR="VLLM_BASE_URL" ;;
    *)
      echo "[papra-addon] FEHLER: Unbekannter 'ai_provider': $AI_PROVIDER"
      exit 1
      ;;
  esac

  # Lokale Provider (Ollama/LM Studio/vLLM) haben sinnvolle Default-Keys und
  # brauchen oft nur die Base-URL, deshalb hier kein Zwangs-Check auf den Key.
  if [ -n "$AI_API_KEY" ]; then
    export "$KEY_VAR"="$AI_API_KEY"
  elif [ "$AI_PROVIDER" != "ollama" ] && [ "$AI_PROVIDER" != "lmstudio" ] && [ "$AI_PROVIDER" != "vllm" ]; then
    echo "[papra-addon] FEHLER: 'ai_is_enabled' ist aktiv mit Provider '$AI_PROVIDER', aber 'ai_api_key' ist leer."
    echo "[papra-addon] Dieser Provider benoetigt einen API-Key."
    exit 1
  fi
  if [ -n "$AI_BASE_URL" ]; then
    export "$URL_VAR"="$AI_BASE_URL"
  fi

  # AUTO_TAGGING_ENABLED ist der server-seitige Master-Schalter fuer die
  # Auto-Tagging-Funktion. Ohne ihn bleibt die "Auto Tagging"-Einstellung in
  # den Organisationseinstellungen von Papra wirkungslos, selbst wenn dort
  # pro Organisation "aktiviert" ausgewaehlt wird.
  AI_AUTO_TAGGING_ENABLED="$(jq -r '.ai_auto_tagging_enabled // false' "$CONFIG_PATH")"
  export AUTO_TAGGING_ENABLED="$AI_AUTO_TAGGING_ENABLED"

  echo "[papra-addon] KI-Funktionen aktiviert: Provider=$AI_PROVIDER Modell=$AI_DEFAULT_MODEL AutoTagging=$AI_AUTO_TAGGING_ENABLED"
  if [ "$AI_AUTO_TAGGING_ENABLED" = "true" ]; then
    echo "[papra-addon] Hinweis: Auto-Tagging muss zusaetzlich pro Organisation"
    echo "[papra-addon] in Papra unter Organisationseinstellungen -> 'Auto Tagging' aktiviert werden."
  fi
else
  echo "[papra-addon] KI-Funktionen deaktiviert (ai_is_enabled=false)."
fi

echo "[papra-addon] Starte Papra auf Port 1221 (APP_BASE_URL=$APP_BASE_URL) ..."

if [ "$#" -eq 0 ]; then
  echo "[papra-addon] FEHLER: Kein Startbefehl (CMD) uebergeben - das sollte nie passieren."
  echo "[papra-addon] Pruefe, ob im Dockerfile sowohl ENTRYPOINT als auch CMD gesetzt sind."
  exit 1
fi

echo "[papra-addon] Befehl: $*"
exec "$@"
