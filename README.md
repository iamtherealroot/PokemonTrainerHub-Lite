# Pokémon Trainer Hub – Lite-Konfiguration

Schlanke, versionierbare Docker-Compose-Ergänzung für eine **bestehende** RomM-Installation auf Debian 13 (Hyper-V, später Proxmox).

## Ausgangslage (16.11.2026)
- VM: `pokehub`, 4 vCPU, 6 GiB RAM; Debian 13.
- Docker: RomM und MariaDB 11 bereits installiert.
- RomM: ca. 1,116 GiB RAM; MariaDB: ca. 190 MiB; Messung im Leerlauf.
- Daten: `/srv/pokemonhub` auf separater ext4-Disk.
- Bestehende Compose-Konfiguration: `/opt/pokemonhub/romm/docker-compose.yml`.

## Ziele
- Zwei Container beibehalten (RomM + MariaDB).
- RAM-Obergrenzen: RomM **2 GiB**, MariaDB **768 MiB**. Limits reduzieren nicht automatisch den tatsächlichen Verbrauch.
- CPU-Kontingent: RomM bis 2 Kerne, MariaDB bis 1 Kern.
- Docker-Logrotation: jeweils 3 × 10 MB.
- Keine Änderungen an ROMs, Spielständen, Benutzerkonten oder Passwörtern.

## Installation auf bestehender VM
1. Repository auf `pokehub` klonen.
2. `sudo bash scripts/apply.sh` ausführen.
3. `sudo bash scripts/check.sh` ausführen und Webzugriff prüfen.
4. Erst nach erfolgreichen Tests Hyper-V herunterfahren und 2 vCPU / zunächst 4 GiB RAM testen.

Das Skript sichert die Compose-Konfiguration, **nicht** die Datenbank. Vor größeren Änderungen vollständige Backups erstellen.

## Grenzen
- Browseremulation findet auf dem Endgerät statt.
- Valkey läuft integriert; kein zusätzlicher Container benötigt.
- 3DS lokal, nicht serverseitig gestreamt.
- Die Override-Datei ergänzt die bestehende Compose-Konfiguration und ersetzt sie nicht.

## Sicherheit
Keine `.env`, ROMs, Spielstände, Datenbanken oder Backups ins Repository committen. Auch öffentliche Metadaten dürfen keine Zugangsdaten enthalten.
