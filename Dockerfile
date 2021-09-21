FROM php:latest
#RUN echo "deb http://us.archive.ubuntu.com/ubuntu" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y jq

COPY entrypoint.sh \
     /action/
COPY phpmd.phar \
     pmphpmd.xml \
     composer.phar \
     composer.json \
     /home/

RUN chmod +x /action/entrypoint.sh

ENTRYPOINT ["/action/entrypoint.sh"]
