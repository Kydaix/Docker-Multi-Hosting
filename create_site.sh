#!/bin/bash

# Variables
SITE_NAME=$1
DOMAIN_NAME=$2
TEMPLATE_FILE="apache/index.html"
DOCKER_COMPOSE_FILE="docker-compose.yml"
NGINX_CONF_DIR="nginx/conf.d"
APACHE_DOC_ROOT="apache/sites/${SITE_NAME}"

# Vérification des paramètres
if [ -z "$SITE_NAME" ] || [ -z "$DOMAIN_NAME" ]; then
    echo "Usage: $0 <site_name> <domain_name>"
    exit 1
fi

# Création du répertoire pour les fichiers de configuration de nginx
mkdir -p $NGINX_CONF_DIR

# Création du fichier de configuration nginx pour le nouveau site
cat <<EOL > $NGINX_CONF_DIR/$DOMAIN_NAME.conf
server {
    listen 80;
    server_name $DOMAIN_NAME;

    location / {
        proxy_pass http://apache;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# Création du répertoire pour les fichiers du nouveau site Apache
mkdir -p $APACHE_DOC_ROOT

# Copie du fichier template dans le répertoire du nouveau site Apache
cp $TEMPLATE_FILE $APACHE_DOC_ROOT/index.html

# Remplacement des placeholders dans le fichier index.html
sed -i "s/\[SITE_NAME\]/$SITE_NAME/g" $APACHE_DOC_ROOT/index.html

# Lancement des conteneurs Docker
docker-compose -f $DOCKER_COMPOSE_FILE up -d --build

echo "Site $SITE_NAME avec le domaine $DOMAIN_NAME créé et lancé avec succès."