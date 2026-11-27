#!/usr/bin/env bash
# Executado pela Vercel a cada envio: instala o Flutter, testa e gera o site.
# Se um teste falhar, a publicação é interrompida.
set -euo pipefail

FLUTTER_VERSION="3.50.1"
FLUTTER_DIR="$(mktemp -d)/flutter"

git clone --quiet --depth 1 --branch "$FLUTTER_VERSION" \
  https://github.com/flutter/flutter.git "$FLUTTER_DIR"
export PATH="$FLUTTER_DIR/bin:$PATH"

flutter config --no-analytics --enable-web
flutter pub get --enforce-lockfile
flutter test
flutter build web --release
