FROM php:latest

COPY entrypoint.sh \
     phpmd.phar \
     pmphpmd.xml \
     /action/

RUN chmod +x /action/entrypoint.sh

ENTRYPOINT ["/action/entrypoint.sh"]
