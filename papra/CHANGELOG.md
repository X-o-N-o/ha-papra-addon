## 26.6.0-8

- Neue Option `ai_auto_tagging_enabled`, gesetzt als `AUTO_TAGGING_ENABLED`.
  Das ist der server-seitige Master-Schalter für Auto-Tagging, den Papra
  zusätzlich zu `AI_IS_ENABLED` benötigt. Ohne ihn bleibt die
  "Auto Tagging"-Einstellung in den Organisationseinstellungen wirkungslos,
  selbst wenn KI-Funktionen allgemein aktiv sind. Standard: aus.
- Hinweis ergänzt: Auto-Tagging muss zusätzlich pro Organisation in der
  Papra-Oberfläche unter Organisationseinstellungen -> "Auto Tagging" aktiv
  geschaltet werden - die Add-on-Optionen schalten die Funktion nur global
  frei, aktivieren sie aber nicht automatisch für jede Organisation.

## 26.6.0-7

- `ai_provider` ist jetzt standardmäßig `openai`, sobald `ai_is_enabled`
  aktiviert wird und kein Provider gewählt wurde - kein zusätzlicher Klick
  mehr nötig für den häufigsten Fall.
- Wenn `ai_provider=openai` und `ai_default_model` leer ist, wird automatisch
  `openai://gpt-4o-mini` verwendet.
- Neue Prüfung: Bei aktivierten KI-Funktionen mit einem Cloud-Provider
  (openai, anthropic, mistral, deepseek, openrouter, cocore) muss
  `ai_api_key` gesetzt sein, sonst bricht der Start mit einer klaren
  Fehlermeldung ab. Lokale Provider (ollama, lmstudio, vllm) sind davon
  ausgenommen, da sie sinnvolle Default-Keys verwenden.

## 26.6.0-6

- Bugfix: Installation/Update schlug fehl mit "invalid options: value must be
  one of [...]. Got ... 'ai_provider': ''". Ursache: Das Schema
  `list(openai|anthropic|...)?` erlaubt zwar, die Option ganz wegzulassen,
  lehnt aber einen vorhandenen leeren String `""` ab - und genau das ist der
  Standardwert von `ai_provider`, solange KI-Funktionen deaktiviert sind.
  `ai_provider` ist jetzt ein einfaches `str?`, die Prüfung auf einen der
  gültigen Provider-Werte (openai, anthropic, mistral, deepseek, openrouter,
  cocore, ollama, lmstudio, vllm) erfolgt weiterhin beim Start in `run.sh`
  mit einer klaren Fehlermeldung bei Tippfehlern.

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
