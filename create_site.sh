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
FTP_HOME="/var/www"
TEMPLATE_FILE="apache/index.html"

# Vérification des arguments
if [ -z "$SITE_NAME" ] || [ -z "$FTP_USER" ] || [ -z "$FTP_PASS" ]; then
  echo "Usage: $0 <site_name> <ftp_username> <ftp_password>"
  exit 1
fi

# Créer le répertoire du site dans le conteneur Apache
docker exec $APACHE_CONTAINER mkdir -p "$APACHE_DOCROOT/$SITE_NAME"
docker exec $APACHE_CONTAINER chown -R www-data:www-data "$APACHE_DOCROOT/$SITE_NAME"

# Copier le template index.html dans le nouveau répertoire du site
docker cp $TEMPLATE_FILE $APACHE_CONTAINER:$APACHE_DOCROOT/$SITE_NAME/index.html

# Fixer les permissions pour le template index.html
docker exec $APACHE_CONTAINER chown www-data:www-data "$APACHE_DOCROOT/$SITE_NAME/index.html"

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

# Créer l'utilisateur FTP uniquement s'il n'existe pas
if ! docker exec $FTP_CONTAINER id -u "$FTP_USER" >/dev/null 2>&1; then
  docker exec $FTP_CONTAINER bash -c "
    useradd -d $FTP_HOME/$SITE_NAME -s /sbin/nologin $FTP_USER && \
    echo -e \"$FTP_PASS\n$FTP_PASS\" | passwd $FTP_USER
  "
fi

# Appliquer les permissions, supposant que 'ftp' est le groupe utilisateur dans le conteneur vsftpd
docker exec $FTP_CONTAINER chown -R ftp:ftp "$FTP_HOME/$SITE_NAME"

# Redémarrer le service vsftpd pour prendre en compte le nouvel utilisateur
docker exec $FTP_CONTAINER service vsftpd restart

# Nettoyage
rm /tmp/$SITE_NAME.conf

echo "Hébergement et utilisateur FTP pour $SITE_NAME créés avec succès."