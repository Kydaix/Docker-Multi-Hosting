#!/bin/bash

# Configuration
SITE_NAME="$1"
FTP_USER="$2"
FTP_PASS="$3"

APACHE_CONTAINER="apache"
NGINX_CONTAINER="nginx"
FTP_CONTAINER="ftp"

# Directories
APACHE_DOCROOT="/usr/local/apache2/htdocs"
NGINX_CONF_DIR="/etc/nginx/conf.d"
FTP_HOME="/home/vsftpd"

# Vérification des arguments
if [ -z "$SITE_NAME" ] || [ -z "$FTP_USER" ] || [ -z "$FTP_PASS" ]; then
  echo "Usage: $0 <site_name> <ftp_username> <ftp_password>"
  exit 1
fi

# Créer le répertoire du site dans le conteneur Apache
docker exec $APACHE_CONTAINER mkdir -p "$APACHE_DOCROOT/$SITE_NAME"
docker exec $APACHE_CONTAINER chown -R www-data:www-data "$APACHE_DOCROOT/$SITE_NAME"

# Créer la configuration Nginx pour le site
NGINX_CONF="
server {
    listen 80;
    server_name $SITE_NAME;

    location / {
        proxy_pass http://$APACHE_CONTAINER;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}"
# Ajouter la configuration Nginx
echo "$NGINX_CONF" > /tmp/$SITE_NAME.conf
docker cp /tmp/$SITE_NAME.conf $NGINX_CONTAINER:$NGINX_CONF_DIR/

# Recharger Nginx pour appliquer la nouvelle configuration
docker exec $NGINX_CONTAINER nginx -s reload

# Créer l'utilisateur FTP
docker exec $FTP_CONTAINER bash -c "echo -e '$FTP_USER\n$FTP_PASS\n$FTP_PASS' | add-user"

# Appliquer les permissions
docker exec $FTP_CONTAINER chown -R ftp:ftp "$FTP_HOME/$FTP_USER"

# Ajouter le lien symbolique vers l'hébergement Apache
docker exec $FTP_CONTAINER ln -s "$APACHE_DOCROOT/$SITE_NAME" "$FTP_HOME/$FTP_USER"

# Nettoyage
rm /tmp/$SITE_NAME.conf

echo "Hébergement et utilisateur FTP pour $SITE_NAME créés avec succès."