## Final bluespice stage
FROM php:8.3-fpm-bookworm

ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64/
ENV OPENSEARCH_JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64/

COPY ./data/099-Custom.php /opt/099-Custom.php
COPY ./data/php.ini /usr/local/etc/php/php.ini
COPY ./data/opcache.blacklist /usr/local/etc/php/opcache.blacklist
COPY ./data/my.cnf /etc/mysql/my.cnf
COPY ./data/bluespice.cron /etc/cron.d/bluespice
COPY ./data/install-scripts /opt/docker/install-scripts
COPY ./data/pingback.js /opt/docker/
COPY ./data/mysqld.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./data/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./data/nginx/bluespice.conf /etc/nginx/sites-available/
COPY ./data/nginx/bluespice-ssl.conf /etc/nginx/sites-available/
COPY ./data/nginx/fastcgi.conf /etc/nginx/
COPY ./data/nginx/nginx.conf /etc/nginx/
# the bluepice archive contains folder with name BlueSpice-free when extracted  
COPY ./_codebase/build-free-4.4.x.tar.bz2 /opt/docker/pkg/BlueSpice-free.tar.bz2
COPY ./data/opensearch-min-no-jdk-with-plugin-2.11.1.tar.bz2 /opt/docker/pkg/opensearch-min-no-jdk-with-plugin-2.11.1.tar.bz2

RUN DEBIAN_FRONTEND="noninteractive" \
    apt-get update && \
    apt-get install -y -o Dpkg::Options::="--force-confdef" \
    cron \
    openjdk-17-jre-headless \
    ghostscript \
    librsvg2-dev \
    poppler-utils \ 
    wget \
    imagemagick\
    memcached \
    logrotate \
    nodejs \
    nginx \
    default-mysql-server && \
    curl -sSL https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions -o - | sh -s gd zip mysqli ldap opcache apcu intl && \
    # download essential packages
    cd /opt/docker && \
    wget https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-runner/9.4.43.v20210629/jetty-runner-9.4.43.v20210629.jar && \
    wget https://buildservice.bluespice.com/webservices/4.2.x/BShtml2PDF.war && \
    wget https://buildservice.bluespice.com/webservices/4.3.x/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
    wget https://getcomposer.org/download/latest-stable/composer.phar -O /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer && \
    # cleanup
    apt-get remove -y wget && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/nginx/sites-available/default && \
    rm -f /etc/nginx/sites-enabled/default && \
    find /usr/local/etc/php-fpm.d/ -type f ! -name 'www.conf' -exec rm -f {} + && \
    chmod a+x /opt/docker/install-scripts/*.sh \
    && mkdir -p /opt/docker/pkg \
    && mkdir -p /opt/docker/bluespice-data/extensions/BluespiceFoundation \
    && mkdir -p /opt/docker/bluespice-data/settings.d \
    && mkdir -p /data \
    && touch /opt/docker/.firstrun

EXPOSE 80
WORKDIR /data
ENTRYPOINT ["/opt/docker/install-scripts/init.sh"]