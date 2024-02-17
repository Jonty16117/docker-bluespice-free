#!/bin/bash

echo "Starting opensearch service"
pgrep -u opensearch > /dev/null && echo "The process opensearch is already running." || su -s /bin/bash -c "/opt/opensearch/bin/opensearch &" opensearch
sleep 5

echo "Starting php-fpm service"
pkill -0 php-fpm && pkill -9 php-fpm
sleep 5
php-fpm --daemonize
sleep 5

echo "Starting mariadb service"
/etc/init.d/mariadb start 
sleep 5

echo "Starting memcached service"
/etc/init.d/memcached start 

echo "Starting jetty service"
JETTY_COMMAND="java -Xms512m -Xmx1024m -Djetty.home=127.0.0.1 -jar /opt/jetty9-runner.jar --port 8080 /opt/BShtml2PDF.war"
if pgrep -f "$JETTY_COMMAND" > /dev/null; then
    echo "jetty is already running."
else
    echo "Starting jetty..."
    nohup $JETTY_COMMAND > /dev/null 2>&1 &
fi

echo "Starting cron service"
/etc/init.d/cron start 

echo "Starting nginx service"
service nginx start
