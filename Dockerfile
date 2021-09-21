FROM php:7.4-cli
#RUN echo "deb http://us.archive.ubuntu.com/ubuntu" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y jq
RUN apt-get install -y git zip


COPY entrypoint.sh \
     /action/
COPY pmphpmd.xml \
     composer.json \
     /home/
COPY composer.phar /usr/local/bin/composer
RUN chmod a+x /usr/local/bin/composer
RUN composer global require phpmd/phpmd

RUN chmod +x /action/entrypoint.sh

ENTRYPOINT ["/action/entrypoint.sh"]
