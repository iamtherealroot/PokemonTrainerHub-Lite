#!/usr/bin/env bash
set -Eeuo pipefail
VERSION="${1:-v0.2.0}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
command -v gh >/dev/null || { echo "GitHub CLI gh fehlt." >&2; exit 1; }
command -v python3 >/dev/null || { echo "Python3 fehlt." >&2; exit 1; }
gh auth status >/dev/null
git diff --quiet && git diff --cached --quiet || { echo "Bitte Änderungen committen." >&2; exit 1; }
if gh release view "$VERSION" >/dev/null 2>&1; then echo "Release existiert bereits."; exit 0; fi
mkdir -p dist
tar -czf "dist/PokemonTrainerHub-Lite-${VERSION}.tar.gz" README.md .gitignore deploy scripts docker-compose.override.yml
python3 - "$VERSION" <<'PY'
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import sys
v=sys.argv[1]
with ZipFile(f"dist/PokemonTrainerHub-Lite-{v}.zip","w",ZIP_DEFLATED) as z:
  for n in ["README.md",".gitignore","docker-compose.override.yml"]:
    z.write(n,n)
  for folder in ["deploy","scripts"]:
    for p in Path(folder).rglob("*"):
      if p.is_file(): z.write(p,str(p))
PY
(cd dist && sha256sum *.zip *.tar.gz > SHA256SUMS)
gh release create "$VERSION" dist/* --target "$(git rev-parse HEAD)" --title "Pokémon Trainer Hub Lite $VERSION" --notes "Portable RomM Lite server package for Debian/Ubuntu; supports bare-metal and VMs. Custom Trainer Hub UI still planned."
echo "Release erfolgreich veröffentlicht."
