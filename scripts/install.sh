#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST=/opt/pokemontrainerhub-lite
DATA=/srv/pokemontrainerhub-lite
BIND=127.0.0.1
PORT=8080
TIMEZONE=Europe/Berlin
DOCKER_INSTALL=0
START=1
usage() {
cat <<'HELP'
Install fresh RomM Lite on Debian 12/13 or Ubuntu 22.04/24.04, bare metal or VM.
Usage: sudo bash scripts/install.sh [--install-docker] [--data-dir PATH]
       [--bind IP] [--port 1-65535] [--timezone REGION/CITY] [--no-start]
IMPORTANT: This installer will NOT migrate an existing RomM installation.
Use scripts/apply.sh for existing RomM deployments.
Defaults: data=/srv/pokemontrainerhub-lite, bind=127.0.0.1, port=8080
HELP
}
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
while (($#)); do
  case "$1" in
    --install-docker) DOCKER_INSTALL=1; shift;;
    --data-dir|--bind|--port|--timezone)
      (($#>=2)) || die "Missing value for $1"
      case "$1" in --data-dir) DATA=$2;; --bind) BIND=$2;; --port) PORT=$2;; --timezone) TIMEZONE=$2;; esac
      shift 2;;
    --no-start) START=0; shift;;
    -h|--help) usage; exit 0;;
    *) die "Unknown argument: $1";;
  esac
done
((EUID==0)) || die "Run as root."
[[ -f /etc/os-release ]] || die "Linux distribution cannot be identified."
. /etc/os-release
case "$ID" in debian|ubuntu) ;; *) die "Only Debian/Ubuntu supported.";; esac
case "$ID:$VERSION_ID" in debian:12|debian:13|ubuntu:22.04|ubuntu:24.04) ;; *) die "OS version not tested/supported.";; esac
command -v openssl >/dev/null || die "Install openssl first."
command -v curl >/dev/null || die "Install curl first."
[[ "$DATA" = /* && "$DATA" != / && "$DATA" != "$DEST" ]] || die "Data directory must be an absolute non-root path."
[[ "$PORT" =~ ^[0-9]+$ ]] && (( PORT>=1 && PORT<=65535 )) || die "Invalid port."
[[ "$BIND" =~ ^[0-9a-fA-F:.]+$ ]] || die "Invalid IP address."
[[ "$TIMEZONE" =~ ^[A-Za-z0-9_+/-]+$ ]] || die "Invalid timezone."
[[ -f "$ROOT/deploy/docker-compose.yml" ]] || die "Deploy compose not found."
[[ ! -e "$DEST/.env" && ! -e "$DEST/docker-compose.yml" ]] || die "Installation exists at $DEST; refusing to overwrite."
[[ ! -e "$DATA/database" && ! -e "$DATA/assets" ]] || die "Existing data found at $DATA; refusing to overwrite."
if ((DOCKER_INSTALL)); then
  if ! command -v docker >/dev/null; then
    apt-get update
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL "https://download.docker.com/linux/$ID/gpg" -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    arch="$(dpkg --print-architecture)"
    printf 'Types: deb\nURIs: https://download.docker.com/linux/%s\nSuites: %s\nComponents: stable\nArchitectures: %s\nSigned-By: /etc/apt/keyrings/docker.asc\n' "$ID" "$VERSION_CODENAME" "$arch" > /etc/apt/sources.list.d/docker.sources
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable --now docker
  fi
fi
command -v docker >/dev/null || die "Docker missing. Use --install-docker."
docker compose version >/dev/null 2>&1 || die "Docker Compose plugin missing. Install it first."
docker info >/dev/null 2>&1 || die "Docker daemon not ready."
mkdir -p "$DEST" "$DATA"
chmod 700 "$DEST"
for dir in database assets resources config redis-data library/roms/gb library/roms/gbc library/roms/gba library/roms/nds library/roms/3ds; do
  mkdir -p "$DATA/$dir"
done
cp "$ROOT/deploy/docker-compose.yml" "$DEST/docker-compose.yml"
umask 077
{
 printf 'DB_PASSWORD=%s\n' "$(openssl rand -hex 32)"
 printf 'DB_ROOT_PASSWORD=%s\n' "$(openssl rand -hex 32)"
 printf 'ROMM_AUTH_SECRET_KEY=%s\n' "$(openssl rand -hex 32)"
 printf 'PTH_DATA_DIR=%s\n' "$DATA"
 printf 'PTH_BIND=%s\n' "$BIND"
 printf 'PTH_PORT=%s\n' "$PORT"
 printf 'TZ=%s\n' "$TIMEZONE"
} > "$DEST/.env"
chmod 600 "$DEST/.env"
cd "$DEST"
docker compose config --quiet || die "Invalid configuration; did not start."
echo "Installed config at $DEST and data at $DATA."
if ((START)); then
  docker compose up -d
  docker compose ps
  echo "RomM will be accessible at http://$BIND:$PORT (127.0.0.1 means local/reverse proxy only)."
else
  echo "Not started (--no-start). Run: cd $DEST && docker compose up -d"
fi
