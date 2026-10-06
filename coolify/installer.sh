#!/usr/bin/env bash
# Télécharge la sauvegarde Coolify chiffrée, la déchiffre avec le mot de passe
# fourni, puis lance la restauration (restaurer-coolify.sh).
set -euo pipefail
BASE="https://raw.githubusercontent.com/end2-237/doc/claude/git-access-recovery-migration-22hpp4/coolify"
DIR=/root/restauration-coolify
mkdir -p "$DIR" && cd "$DIR"

echo "Téléchargement…"
curl -fsSL "$BASE/coolify-db-propre.sql.gz.enc" -o coolify-db-propre.sql.gz.enc
curl -fsSL "$BASE/restaurer-coolify.sh" -o restaurer-coolify.sh

read -r -s -p "Mot de passe de la sauvegarde (rien ne s'affiche, c'est normal) : " PHRASE; echo
if ! printf '%s' "$PHRASE" | openssl enc -d -aes-256-cbc -pbkdf2 -iter 600000 \
      -in coolify-db-propre.sql.gz.enc -out coolify-db-propre.sql.gz -pass stdin 2>/dev/null \
   || ! gzip -t coolify-db-propre.sql.gz 2>/dev/null; then
  rm -f coolify-db-propre.sql.gz
  echo "Mot de passe incorrect. Relance : bash $DIR/../installer.sh"; exit 1
fi
rm -f coolify-db-propre.sql.gz.enc
echo "Sauvegarde déchiffrée ✓"
bash restaurer-coolify.sh coolify-db-propre.sql.gz
