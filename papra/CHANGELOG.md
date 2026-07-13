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
