#!/bin/bash

# Setup bluespice wiki

echo "Setting up new bluespice wiki"
rm -rf /data/www
mkdir -p /data/www
build_file=/opt/docker/pkg/BlueSpice-free.tar.bz2
tar -xf $build_file --directory /data/www 
mv /data/www/BlueSpice-free /data/www/w
mkdir -p /data/www/bluespice
mv /data/www/w /data/www/bluespice
rm -rf $build_file
ln -sf /opt/099-Custom.php /data/www/bluespice/w/settings.d/099-Custom.php

DB_NAME="bluespice"
DB_USER="bluespice"
DB_PASSWORD="$BS_DB_PASSWORD"

# Check if the Bluespice database exists
if ! /usr/bin/mysql -u root -e "USE $DB_NAME" 2>/dev/null; then
    /usr/bin/mysql -u root -e "CREATE DATABASE $DB_NAME"
    /usr/bin/mysql -u root -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY \"$DB_PASSWORD\""
    /usr/bin/mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* to '$DB_USER'@'localhost'"
    /usr/bin/mysql -u root -e "FLUSH PRIVILEGES"
    echo "Bluespice database and user created successfully."
else
    echo "Bluespice database already exists. Skipping creation."
fi
sleep 5

if [ -f "/data/cert/ssl.cert" ] && [ -f "/data/cert/ssl.key" ]; then
    sed -i "s/{CERTFILE}/\/data\/cert\/ssl.cert/g" /etc/nginx/sites-available/bluespice-ssl.conf
    sed -i "s/{KEYFILE}/\/data\/cert\/ssl.key/g" /etc/nginx/sites-available/bluespice-ssl.conf
    rm -f /etc/nginx/sites-enabled/bluespice.conf
    ln -s /etc/nginx/sites-available/bluespice-ssl.conf /etc/nginx/sites-enabled/
fi
echo ".."

php /data/www/bluespice/w/maintenance/install.php --confpath=/data/www/bluespice/w --dbname=bluespice --dbuser=bluespice --dbpass=${BS_DB_PASSWORD} --dbserver=127.0.0.1 --lang=${BS_LANG} --pass=${BS_PASSWORD} --scriptpath=/w --server=${BS_URL}:${BS_PORT} "${BS_NAME}" $BS_USER 

echo "copying bluespice foundation data and config folders..." 
mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/data 
cp -r /data/www/bluespice/w/extensions/BlueSpiceFoundation/data.template/. /data/www/bluespice/w/extensions/BlueSpiceFoundation/data/ 
echo "copied bluespice foundation data and config folders" 
php /data/www/bluespice/w/maintenance/update.php --quick 
php /data/www/bluespice/w/maintenance/createAndPromote.php --force --sysop "$BS_USER" "$BS_PASSWORD" 
php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/initBackends.php --quick 
php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/rebuildIndex.php --quick 
php /data/www/bluespice/w/maintenance/runJobs.php --memory-limit=max --maxjobs=50 

# Setup file permissions
/opt/docker/install-scripts/setwikiperm.sh /data/www/bluespice/w
