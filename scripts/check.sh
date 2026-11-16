#!/usr/bin/env bash
set -Eeuo pipefail
cd /opt/pokemonhub/romm
free -h
uptime
docker compose ps
docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}'
docker inspect pokemonhub-romm --format 'RomM RAM-Grenze: {{.HostConfig.Memory}} Bytes'
docker inspect pokemonhub-db --format 'MariaDB RAM-Grenze: {{.HostConfig.Memory}} Bytes'
curl -sSI --max-time 15 http://127.0.0.1:8080 | head -n 1 || true
