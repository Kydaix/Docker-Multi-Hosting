FROM httpd:latest

# Copier les configurations personnalisées
COPY apache2.conf /usr/local/apache2/conf/apache2.conf
COPY site.conf /usr/local/apache2/conf/extra/site.conf

# Configurer ProFTPD
RUN apt-get update && apt-get install -y proftpd && \
    mkdir -p /var/www/html && \
    echo "Include /usr/local/apache2/conf/extra/site.conf" >> /usr/local/apache2/conf/httpd.conf && \
    service proftpd start

COPY ftpd.conf /etc/proftpd/proftpd.conf