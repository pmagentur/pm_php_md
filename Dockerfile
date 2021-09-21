FROM php:latest

RUN apk add --no-cache jq

COPY entrypoint.sh \
     /action/
COPY phpmd.phar \
     pmphpmd.xml \
     /home/

RUN chmod +x /action/entrypoint.sh

ENTRYPOINT ["/action/entrypoint.sh"]
