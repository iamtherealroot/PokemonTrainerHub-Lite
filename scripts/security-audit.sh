#!/usr/bin/env bash
# Read-only audit for new or existing RomM Lite deployments. No secrets are printed.
set -u
if [ "$EUID" -ne 0 ]; then echo "Bitte mit sudo ausführen."; exit 1; fi
echo "=== PokemonTrainerHub-Lite Security Audit (read-only) ==="
echo "=== Host ==="
cat /etc/os-release | grep -E '^(PRETTY_NAME|VERSION_ID)=' || true
echo "=== Listeners / 8080, 3306, 6379 ==="
ss -lntp 2>/dev/null | grep -E '(:8080|:3306|:6379)([[:space:]]|$)' || echo "Keine passenden Host-TCP-Listener erkannt"
echo "=== Docker published ports ==="
if command -v docker >/dev/null && docker info >/dev/null 2>&1; then
 docker ps --format 'table {{.Names}}\t{{.Ports}}'
 echo "=== Security-related runtime limits ==="
 for name in pokemonhub-romm pokemonhub-db; do
  if docker inspect "$name" >/dev/null 2>&1; then
    docker inspect "$name" --format 'Container: {{.Name}} / MemoryLimit: {{.HostConfig.Memory}} / Privileged: {{.HostConfig.Privileged}} / ReadOnlyRootfs: {{.HostConfig.ReadonlyRootfs}}'
  fi
 done
else
 echo "Docker nicht verfügbar oder Dienst nicht erreichbar"
fi
echo "=== SSH state ==="
systemctl is-active ssh 2>/dev/null || true
echo "=== Firewall service state ==="
systemctl is-active ufw 2>/dev/null || true
systemctl is-active nftables 2>/dev/null || true
echo "=== Findings ==="
echo "ACHTUNG: Host-Listener und docker ps sind keine vollständige externe Portprüfung."
echo "ACHTUNG: Docker Port-Publishing kann gewöhnliche UFW-Regeln umgehen."
echo "Für NPM auf anderem Host nur die private Server-IP binden und Zugriff auf die NPM-IP begrenzen."
echo "Vor öffentlichem Betrieb von außerhalb des LAN IPv4 und IPv6 testen."
