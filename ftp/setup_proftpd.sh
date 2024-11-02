#!/bin/bash

# Start syslogd for logging (Debian-based systems)
service rsyslog start

# Create necessary directories and files if they do not exist
mkdir -p /var/www/html
mkdir -p /home/ftpusers

# Start the proftpd service
proftpd --nodaemon -c /etc/proftpd/proftpd.conf