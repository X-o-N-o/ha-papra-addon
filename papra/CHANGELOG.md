## 26.6.0-2

- Bugfix: fehlendes `CMD` im Dockerfile ergänzt. Das eigene `ENTRYPOINT`
  hatte das von Papra geerbte `CMD` überschrieben, wodurch der Container
  ohne Fehlermeldung sofort wieder beendet wurde (Start/Stop-Schleife).

## 26.6.0-1

- Erstversion des Papra Home-Assistant-Add-ons.
