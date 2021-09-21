FROM php:latest

COPY entrypoint.sh \
     pmphpmd.xml \
     /action/

RUN chmod +x /action/entrypoint.sh

ENTRYPOINT ["/action/entrypoint.sh"]
