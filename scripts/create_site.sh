#!/bin/bash

SITE_NAME=$1

if [ -z "$SITE_NAME" ]; then
  echo "Usage: $0 <site-name>"
  exit 1
fi

SITE_DIR="./sites/$SITE_NAME"
TEMPLATE_DIR="./sites/site_template"

# Copy template to new site directory
cp -r $TEMPLATE_DIR $SITE_DIR

# Create Dockerfile for the new site
cat > $SITE_DIR/Dockerfile <<EOL
FROM httpd:latest
COPY apache2.conf /usr/local/apache2/conf/apache2.conf
COPY site.conf /usr/local/apache2/conf/extra/site.conf
RUN apt-get update && apt-get install -y proftpd
COPY ftpd.conf /etc/proftpd/proftpd.conf
EOL

# Build Docker Image
docker build -t ${SITE_NAME}_image $SITE_DIR

# Run Docker Container
docker run -d --name $SITE_NAME -p 0.0.0.0:$(shuf -i 8000-9000 -n 1):80 --network=webnet ${SITE_NAME}_image

# Print success message
echo "Site $SITE_NAME created and running."