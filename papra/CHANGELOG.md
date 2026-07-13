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
