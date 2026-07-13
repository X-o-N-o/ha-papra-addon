## 26.6.0-5

- Neue Option `document_storage_path`: Wenn gesetzt, legt Papra Dokumente
  nicht mehr lokal unter `/data/app-data/documents`, sondern in dem
  angegebenen Unterordner der Home-Assistant-Netzwerkfreigabe `share` ab
  (`/share/<document_storage_path>`). Damit lassen sich Dokumente auf einem
  eigenen NAS speichern, sofern die Freigabe vorher unter Einstellungen ->
  System -> Speicher -> Netzwerkspeicher als SMB/NFS-Mount eingebunden wurde.
  Die Datenbank (`db.sqlite`) bleibt bewusst weiterhin lokal unter `/data`,
  da SQLite über Netzwerkfreigaben unzuverlässig laufen kann. Leer lassen,
  um wie bisher lokal zu speichern.
- Neue KI-Optionen (`ai_is_enabled`, `ai_provider`, `ai_api_key`,
  `ai_base_url`, `ai_default_model`) zum Aktivieren von Papras KI-Funktionen
  (z.B. automatisches Tagging). Master-Schalter ist standardmäßig aus
  (`ai_is_enabled: false`). Bei Aktivierung werden je nach gewähltem
  Provider automatisch die passenden Papra-Umgebungsvariablen gesetzt
  (z.B. `OPENAI_API_KEY`/`OPENAI_BASE_URL` für `openai`, `ANTHROPIC_API_KEY`
  für `anthropic`, usw.). Unterstützte Provider: openai, anthropic, mistral,
  deepseek, openrouter, cocore, ollama, lmstudio, vllm.

## 26.6.0-4

- Bugfix: `CMD` von `node dist/index.js` auf `pnpm start:with-migrations`
  korrigiert. Der vorherige Befehl übersprang die Datenbank-Migrationen,
  wodurch Tabellen wie `users` nie angelegt wurden und Registrierung/Login
  mit "SQLITE_ERROR: no such table: users" fehlschlugen.
- Achtung: Bereits angelegte, aber unvollständige `db.sqlite`-Dateien aus
  vorherigen Startversuchen sollten vor dem nächsten Start gelöscht werden
  (siehe Anleitung), damit die Migrationen sauber von vorne laufen.

## 26.6.0-3

- Neue Pflichtoption `app_base_url` ergänzt und als `APP_BASE_URL` an Papra
  übergeben. Papra vergleicht diese URL mit der tatsächlich aufgerufenen
  Origin und bricht sonst mit "Ungültige Anwendungs-Ursprung" ab.

## 26.6.0-2

- Bugfix: fehlendes `CMD` im Dockerfile ergänzt. Das eigene `ENTRYPOINT`
  hatte das von Papra geerbte `CMD` überschrieben, wodurch der Container
  ohne Fehlermeldung sofort wieder beendet wurde (Start/Stop-Schleife).

## 26.6.0-1

- Erstversion des Papra Home-Assistant-Add-ons.
