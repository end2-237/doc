#!/usr/bin/env bash
# Restaure une sauvegarde Coolify NETTOYÉE (coolify-db-propre.sql.gz) dans un
# Coolify tout juste installé, avec sa NOUVELLE APP_KEY.
#
# Prérequis :
#   - Coolify fraîchement installé et démarré (conteneurs coolify, coolify-db…)
#   - le fichier coolify-db-propre.sql.gz dans le même dossier que ce script
# Utilisation : bash restaurer-coolify.sh
set -euo pipefail

DUMP="${1:-coolify-db-propre.sql.gz}"
PSQL=(docker exec -i coolify-db psql -U coolify -v ON_ERROR_STOP=1 -q)
[ -f "$DUMP" ] || { echo "Fichier $DUMP introuvable."; exit 1; }
docker ps --format '{{.Names}}' | grep -qx coolify-db || { echo "Le conteneur coolify-db ne tourne pas. Installe Coolify d'abord."; exit 1; }

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

echo "1/7 Sauvegarde de sécurité de la base actuelle (au cas où)…"
docker exec coolify-db pg_dump -U coolify -d coolify | gzip > "/root/coolify-avant-restauration-$(date +%F-%H%M).sql.gz"

echo "2/7 Récupération de la clé SSH localhost du NOUVEAU Coolify (chiffrée avec la nouvelle APP_KEY)…"
NEW_KEY=$(docker exec coolify-db psql -U coolify -d coolify -At -c \
  "select private_key from private_keys where id = (select private_key_id from servers where id = 0)")
[ -n "$NEW_KEY" ] || { echo "Clé localhost introuvable dans le nouveau Coolify. Arrêt (rien n'a été modifié)."; exit 1; }
docker exec coolify-db pg_dump -U coolify -d coolify --data-only --column-inserts -t ssl_certificates > "$TMP/ssl.sql" || true

echo "3/7 Arrêt de Coolify (la base reste allumée)…"
docker stop coolify coolify-realtime >/dev/null 2>&1 || true

echo "4/7 Remplacement de la base par la sauvegarde nettoyée…"
docker exec coolify-db psql -U coolify -d postgres -q -c "DROP DATABASE coolify WITH (FORCE);" -c "CREATE DATABASE coolify OWNER coolify;"
gunzip -c "$DUMP" | "${PSQL[@]}" -d coolify > "$TMP/restore.log"

echo "5/7 Pose de la nouvelle clé SSH localhost…"
printf "update private_keys set private_key = %s where id = (select private_key_id from servers where id = 0);\n" \
  "\$cle\$${NEW_KEY}\$cle\$" | "${PSQL[@]}" -d coolify

echo "6/7 Redémarrage de Coolify et mise à jour du schéma…"
docker start coolify coolify-realtime >/dev/null
sleep 20
docker exec coolify php artisan migrate --force

echo "7/7 Certificats internes du nouveau Coolify…"
if [ -s "$TMP/ssl.sql" ]; then
  "${PSQL[@]}" -d coolify < "$TMP/ssl.sql" || echo "  (certificats non réimportés : Coolify les recréera)"
  "${PSQL[@]}" -d coolify -c "select setval(pg_get_serial_sequence('ssl_certificates','id'), coalesce((select max(id) from ssl_certificates),1));" >/dev/null || true
fi
docker restart coolify >/dev/null

echo
echo "Terminé. Ouvre Coolify : il te demandera de choisir un NOUVEAU mot de passe."
echo "Ensuite, pour chaque application : remplis les variables d'environnement (vides),"
echo "puis redéploie. Voir l'INVENTAIRE COOLIFY sur ton Drive."
