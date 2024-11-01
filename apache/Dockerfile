FROM httpd:latest
COPY ./sites/ /usr/local/apache2/htdocs/

RUN apt-get update \
    && apt-get install -y vim \
    && apt-get clean