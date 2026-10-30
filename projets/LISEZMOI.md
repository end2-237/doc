# Projets chiffrés

Chaque dossier `projets/<nom>/` contient un projet chiffré pour le serveur :

- `cle.enc` : clé AES chiffrée avec la clé publique RSA du serveur (OAEP, SHA-256) ;
- `paquet.enc` : le dépôt git (bundle) chiffré en AES-256-CBC (PBKDF2, 200 000 itérations) ;
- `paquet.sha256` : l'empreinte du bundle en clair, vérifiée après déchiffrement.

Seul le serveur détient la clé privée (`/root/.cle-projets/prive.pem`). Sur le serveur :

    ~/recevoir.sh <nom>

déchiffre le paquet, crée `bedev24-1/<nom>` en privé s'il n'existe pas, et y pousse la branche `main`.
