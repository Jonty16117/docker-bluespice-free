#!/bin/bash

echo "Old installation detected! Moving old installation to /data/backups/$CURR_TIMESTAMP"
/etc/init.d/memcached start
sleep 10
chown -Rf mysql:mysql /data/mysql
rm -Rf /var/lib/mysql 
ln -s /data/mysql /var/lib/mysql 
/etc/init.d/mariadb start
mkdir -p /data/backups/
mv /data/www/bluespice /data/backups/$CURR_TIMESTAMP

total_backups=$(find "$WIKI_BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)
if [ "$total_backups" -gt "$WIKI_BACKUP_LIMIT" ]; then
    oldest_backup=$(find "$WIKI_BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d -exec stat --format="%Y %n" {} + | sort -n | head -n 1 | awk '{print $2}')
    rm -rf $oldest_backup
    echo "Cleaned old backup $oldest_backup"
fi
