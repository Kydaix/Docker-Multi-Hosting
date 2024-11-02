#!/bin/bash

# Create necessary directories and files
mkdir -p /var/run/vsftpd/empty
mkdir -p /home/ftpusers

# Un-comment the following lines if SSL certificates are required
# mkdir -p /etc/ssl/private
# mkdir -p /etc/ssl/certs
# openssl req -new -x509 -days 365 -nodes -out /etc/ssl/certs/ssl-cert-snakeoil.pem -keyout /etc/ssl/private/ssl-cert-snakeoil.key -subj "/C=US/ST=Oregon/L=Portland/O=Company Name/OU=Org/CN=example.com"

# Start the vsftpd service
/usr/sbin/vsftpd /etc/vsftpd.conf