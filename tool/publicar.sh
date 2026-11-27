#!/bin/sh
# Gera a versão web e publica na Vercel. Executar na raiz do projeto.
set -e
flutter build web --release
pasta="$(mktemp -d)/ux-flutter-bloco3"
mkdir -p "$pasta"
cp -r build/web/. "$pasta"/
cd "$pasta"
npx --yes vercel@latest link --yes --project ux-flutter-bloco3
npx --yes vercel@latest deploy --prod --yes
