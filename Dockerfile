FROM php:7.4-cli

RUN apt-get update
RUN apt-get install -y jq
RUN apt-get install -y git zip


COPY entrypoint.sh \
     parse_phpmd.py\
     /action/
COPY pmphpmd.xml \
     /home/
COPY composer.phar /usr/local/bin/composer

RUN chmod a+x /usr/local/bin/composer
RUN composer global require phpmd/phpmd mridang/pmd-annotations
ENV PATH=/root/.composer/vendor/bin:${PATH}
RUN chmod +x /action/entrypoint.sh
RUN chmod +x /action/parse_phpmd.py

ENTRYPOINT ["/action/entrypoint.sh"]
