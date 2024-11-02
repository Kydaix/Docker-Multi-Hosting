#!/bin/bash

SITE_NAME=$1
SITE_PATH="./apache/sites/$SITE_NAME"

if [ -z "$SITE_NAME" ]; then
    echo "Veuillez spécifier un nom pour le site."
    exit 1
fi

mkdir -p $SITE_PATH

# Créer un fichier index par défaut
echo "<html><body><h1>Bienvenue sur $SITE_NAME</h1></body></html>" > $SITE_PATH/index.html

echo "Site '$SITE_NAME' créé dans $SITE_PATH."
docker compose restart apache
