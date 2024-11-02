FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y vsftpd && \
    apt-get clean

COPY vsftpd.conf /etc/vsftpd.conf
COPY setup_vsftpd.sh /setup_vsftpd.sh

RUN chmod +x /setup_vsftpd.sh

# Expose FTP port
EXPOSE 21 30000-30009

CMD ["/setup_vsftpd.sh"]