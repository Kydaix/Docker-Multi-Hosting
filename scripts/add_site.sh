#!/bin/bash

SITE_NAME=$1
DOCUMENT_ROOT="/var/www/${SITE_NAME}"

if [ -z "$SITE_NAME" ]; then
    echo "Usage: $0 <site-name>"
    exit 1
fi

# Create document root
mkdir -p $DOCUMENT_ROOT

# Create Apache configuration
cat <<EOL > ../apache/sites-available/${SITE_NAME}.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot $DOCUMENT_ROOT

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory "$DOCUMENT_ROOT">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOL

# Enable Apache site
ln -s ../apache/sites-available/${SITE_NAME}.conf ../apache/sites-enabled/

# Restart Apache container
docker-compose restart apache

echo "Site $SITE_NAME created and enabled."