FROM fakereto/nginx-fpm:14-php-7.3
LABEL maintainer="Andres Vejar <andresvejar@neubox.net>"

# add bitbucket and github to known hosts for ssh needs
WORKDIR /root/.ssh
RUN chmod 0600 /root/.ssh \
    && ssh-keyscan -t rsa bitbucket.org >> known_hosts \
    && ssh-keyscan -t rsa github.com >> known_hosts \
    phpdismod xdebug
# install composer so we can run dump-autoload at entrypoint startup in dev
# copied from official composer Dockerfile
ENV PATH="/composer/vendor/bin:$PATH" \
    COMPOSER_ALLOW_SUPERUSER=1

# Lumen App Config
# setup app config environment at runtime
# gets put into ./.env at startup
ENV APP_NAME=Lumen \
    APP_ENV=local \
    APP_DEBUG=true \
    APP_KEY=KEYGOESHERE \
    APP_LOG=errorlog \
    APP_URL=http://localhost \
    DB_CONNECTION=mysql \
    DB_HOST=mysql \
    DB_PORT=3306 \
    DB_DATABASE=homestead \
    DB_USERNAME=homestead \
    DB_PASSWORD=secret \
    CACHE_DRIVER=file \
    QUEUE_CONNECTION=sync \
    LOG_CHANNEL=stdout \
    LOG_SLACK_WEBHOOK_URL=NONE
# Many more ENV may be needed here, and updated in docker-phpfpm-entrypoint file
COPY ./config/app.conf ${NGINX_CONF_DIR}/sites-enabled/app.conf

COPY docker-lumen-entrypoint.sh /var/www/
ENTRYPOINT ["/var/www/docker-lumen-entrypoint.sh"]

WORKDIR /var/www/app
COPY --chown=www-data:www-data ./src .

EXPOSE 80 443 9000 9001
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]