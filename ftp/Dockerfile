FROM debian:latest

RUN apt-get update && \
    apt-get install -y proftpd && \
    apt-get clean

COPY proftpd.conf /etc/proftpd/proftpd.conf
COPY setup_proftpd.sh /setup_proftpd.sh

RUN chmod +x /setup_proftpd.sh

EXPOSE 21 30000-30009

CMD ["/setup_proftpd.sh"]