#!/bin/bash

# Nom du site
SITE_NAME=$1
if [ -z "$SITE_NAME" ]; then
  echo "Usage: $0 <site_name>"
  exit 1
fi

# Créer le dossier du site
mkdir -p "../sites/$SITE_NAME"
echo "<h1>Welcome to $SITE_NAME</h1>" > "../sites/$SITE_NAME/index.html"

# Rajouter une ligne dans le vhost Apache
cat <<EOL >"../apache/vhost.conf"
<VirtualHost *:80>
    DocumentRoot "/var/www/html/$SITE_NAME"
    ServerName $SITE_NAME

    <Directory "/var/www/html/$SITE_NAME">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/$SITE_NAME-error.log
    CustomLog ${APACHE_LOG_DIR}/$SITE_NAME-access.log combined
</VirtualHost>
EOL

# Redémarrer les services Apache et Nginx pour prendre en compte les modifications
docker compose restart apache
docker compose restart nginx

echo "Site $SITE_NAME créé avec succès."