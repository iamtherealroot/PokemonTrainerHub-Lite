#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo 'Bitte als root ausführen.' >&2; exit 1; }
BASE=/opt/pokemonhub/romm
FILE="$BASE/docker-compose.override.yml"
SRC="$(cd "$(dirname "$0")/.." && pwd)/docker-compose.override.yml"
[[ -f "$BASE/docker-compose.yml" && -f "$BASE/.env" ]] || { echo 'Bestehende RomM-Konfiguration fehlt.' >&2; exit 1; }
mountpoint -q /srv/pokemonhub || { echo 'ACHTUNG: Datenplatte nicht gemountet.' >&2; exit 1; }
cd "$BASE"
mkdir -p /srv/pokemonhub/backups/config
STAMP=$(date +%Y%m%d-%H%M%S)
cp -a docker-compose.yml "/srv/pokemonhub/backups/config/docker-compose.yml.$STAMP"
if [[ -f docker-compose.override.yml ]]; then cp -a docker-compose.override.yml "/srv/pokemonhub/backups/config/docker-compose.override.yml.$STAMP"; fi
cp "$SRC" "$FILE"
chmod 644 "$FILE"
if ! docker compose config --quiet; then echo 'Ungültige Compose-Konfiguration; vorherige Override ggf. aus Backup wiederherstellen.' >&2; exit 1; fi
docker compose up -d --no-build
docker compose ps
docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}'
