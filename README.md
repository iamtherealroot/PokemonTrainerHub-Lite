# 🎮 Pokémon Trainer Hub Lite

**Deine Retro-Spielebibliothek. Dein Server. Deine Spielstände.**

PokemonTrainerHub-Lite ist ein leichtgewichtiges, selbst hostbares Serverpaket rund um [RomM](https://romm.app/). Es organisiert Retrospiele und Speicherstände auf der eigenen Hardware – vom kleinen Bare-Metal-Server bis zur VM in Hyper-V, Proxmox, KVM oder VMware.

> **Projektstatus: v0.2.0 – Server-Grundlage.** Eine eigene Pokémon-Traineroberfläche, eigene Achievements, zentrale Trainerlevel und 3DS-Integration sind geplant, aber **noch nicht enthalten**. Bestehende RetroAchievements hängen von kompatiblen lokalen Emulatoren und deren Anbindung ab.

## ✨ Highlights

- 🐧 **Debian 12/13 und Ubuntu 22.04/24.04** als Zielsysteme (x86-64; andere Distributionen noch nicht getestet)
- 🖥️ **Bare Metal oder VM:** keine Hypervisor-Abhängigkeit
- 🐳 **Docker Compose:** RomM und MariaDB, mit integriertem In-Memory-Store
- 🌐 **Browserbibliothek & Emulation:** abhängig von den von RomM/EmulatorJS unterstützten Plattformen
- 🎮 **GB, GBC, GBA und DS:** ROM-Verzeichnisse bei der Einrichtung vorbereitet
- 💾 **Dauerhafte Daten:** auf einem separat festlegbaren Pfad
- 🔒 **Zugangsdaten:** lokal generiert; nicht im Git-Repository
- 📉 **Ressourcenlimits:** RomM 2 GiB, MariaDB 768 MiB; Logrotation; 2/1 CPU-Kontingente
- 🛡️ **Sicherer Standard:** Webport nur auf localhost; Veröffentlichung über Reverse Proxy oder bewusstes LAN-Binding
- ♻️ **Zwei Installationswege:** frischer Server oder vorhandene RomM-Installation

## 📦 Download

**[Alle GitHub-Releases](https://github.com/iamtherealroot/PokemonTrainerHub-Lite/releases)**

Vorgesehene Release-Dateien für v0.2.0: `PokemonTrainerHub-Lite-v0.2.0.zip`, `PokemonTrainerHub-Lite-v0.2.0.tar.gz` und `SHA256SUMS`. Die Dateien werden durch GitHub Actions erstellt; bitte zuerst prüfen, ob das Release veröffentlicht wurde.

Alternativ direkt aus Git installieren:

```bash
sudo apt update
sudo apt install -y git curl openssl ca-certificates
git clone https://github.com/iamtherealroot/PokemonTrainerHub-Lite.git
cd PokemonTrainerHub-Lite
```

## 🚀 Neuinstallation (Debian/Ubuntu)

**Nur auf einem frischen Zielsystem verwenden!** Vor der Installation Datenpfad und freie Ports prüfen.

Mit Docker-Installation:

```bash
sudo bash scripts/install.sh --install-docker --bind 0.0.0.0
```

Ohne Docker-Installation (Docker Engine + Compose-Plugin bereits vorhanden):

```bash
sudo bash scripts/install.sh --bind 0.0.0.0
```

Standardmäßig lauscht der Dienst **nur auf 127.0.0.1:8080**. `--bind 0.0.0.0` stellt ihn im Netzwerk bereit; nur in einem geschützten LAN verwenden, niemals ohne TLS/Auth-Konzept direkt am Internet exponieren.

Anpassung von Speicherpfad und Port:

```bash
sudo bash scripts/install.sh --install-docker \
  --data-dir /srv/retro-library \
  --bind 127.0.0.1 --port 8080
```

Die Anwendung wird unter `/opt/pokemontrainerhub-lite` eingerichtet, Daten liegen standardmäßig unter `/srv/pokemontrainerhub-lite`.

Nach dem Start:

```bash
sudo docker compose -f /opt/pokemontrainerhub-lite/docker-compose.yml \
  --env-file /opt/pokemontrainerhub-lite/.env ps
```

Bei LAN-Binding im Browser `http://SERVER-IP:8080` aufrufen und das Konto einrichten.

## 🔧 Bestehende RomM-Installation optimieren

Für bestehende Deployments wie unsere Hyper-V-Testumgebung **nicht** `install.sh` verwenden. Der vorhandene Optimierungsweg setzt voraus:

- Compose-Datei: `/opt/pokemonhub/romm/docker-compose.yml`
- Geschützte .env-Datei daneben
- Eingebundener Datenpfad: `/srv/pokemonhub`

```bash
sudo bash scripts/apply.sh
sudo bash scripts/check.sh
```

Das Skript sichert Compose-Konfigurationen, **nicht** die Datenbank oder ROMs. Unbedingt vorher eigene vollständige Backups erstellen.

## 📊 Ressourcenbedarf

| Dienst | RAM-Limit | CPU-Kontingent |
|---|---:|---:|
| RomM | 2 GiB | 2 CPUs |
| MariaDB | 768 MiB | 1 CPU |

Dies sind **Obergrenzen, keine Verbrauchs- oder Hardwaregarantie**. Für kleine Installationen zunächst 4 GiB VM-RAM und 2 vCPU testen, danach messen. Browseremulation findet auf den Endgeräten statt.

## 🔐 Datenschutz und Rechtliches

Keine ROMs, BIOS-Dateien, Passwörter, private Datenbanken oder Speicherstände in dieses Repository einchecken. Spiele und erforderliche Firmware sind selbst und rechtmäßig bereitzustellen. Im öffentlichen Git-Repository liegen ausschließlich die Installationsdateien.

## 🗺️ Roadmap

1. RomM-Serverpaket und reproduzierbare Releases
2. Konto- und Spielstand-Synchronisierung im Hybridbetrieb
3. Eigenständiger Pokémon Trainer Hub mit UI, Trainerprofilen und XP
4. Eigene Achievements und RetroAchievements-Anbindung
5. Weitergehende 3DS-Unterstützung

**Hinweis:** Das Repository ist ein unabhängiges Community-Projekt und nicht mit Nintendo, The Pokémon Company oder RomM verbunden.
