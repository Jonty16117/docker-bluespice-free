#!/bin/bash

## NOTE: The order in which the services and processes are run and started matters and do not simply change them without knowing what you are doing

set -e

mkdir -p /data/logs/

if [ -z $BS_DB_PASSWORD ]; then
    BS_DB_PASSWORD="ThisIsDBPassword"
fi
if [ -z $BS_LANG ]; then
    BS_LANG="en"
fi
if [ -z $BS_URL ]; then
    BS_URL="http://127.0.0.1"
fi
if [ -z $BS_USER ]; then
    BS_USER="WikiSysop"
fi
if [ -z $BS_PASSWORD ]; then
    BS_PASSWORD="PleaseChangeMe"
fi
if [ -z $BS_NAME ]; then
    BS_NAME="Bluespice"
fi
if [ -z $HTTPS_PORT ]; then
    HTTPS_PORT="443"
fi
if [ -z $HTTP_PORT ]; then
    HTTP_PORT="80"
fi

if [[ $BS_URL = https* ]]; then
    BS_PORT=$HTTPS_PORT
else
    BS_PORT=$HTTP_PORT
fi

if [ -z $WIKI_BACKUP_LIMIT ] || ! [ "$WIKI_BACKUP_LIMIT" -gt 0 ]; then
    WIKI_BACKUP_LIMIT=5
fi

CURR_TIMESTAMP=$(date +%s)
WIKI_BACKUP_DIR="/data/backups"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
SETUP_SERVICES=$SCRIPT_DIR/setup-services.sh
SETUP_NEW_WIKI=$SCRIPT_DIR/setup-new-wiki.sh
BACKUP_WIKI=$SCRIPT_DIR/backup-wiki.sh
RESTORE_WIKI=$SCRIPT_DIR/restore-wiki.sh
START_SERVICES=$SCRIPT_DIR/start-services.sh
UPDATE_WIKI=$SCRIPT_DIR/update-wiki.sh
UPGRADE_WIKI_FLAG=false
FRESH_INSTALL_FLAG=false
UPDATE_WIKI_FLAG=false

if [ -f "/opt/docker/.firstrun" ]; then
    if [[ -d "/data/mysql" ]] && [[ -f "/data/www/bluespice/w/LocalSettings.php" ]]; then
        UPGRADE_WIKI_FLAG=true
    else
        FRESH_INSTALL_FLAG=true
    fi
    rm /opt/docker/.firstrun
else
    UPDATE_WIKI_FLAG=true
fi

# sleep infinity

echo UPGRADE_WIKI_FLAG: $UPGRADE_WIKI_FLAG
echo FRESH_INSTALL_FLAG: $FRESH_INSTALL_FLAG
echo UPDATE_WIKI_FLAG: $UPDATE_WIKI_FLAG

[ "$UPGRADE_WIKI_FLAG" = true ] && source $BACKUP_WIKI
[ "$UPDATE_WIKI_FLAG" = false ] && source $SETUP_SERVICES
source $START_SERVICES
[ "$UPDATE_WIKI_FLAG" = false ] && source $SETUP_NEW_WIKI
[ "$UPGRADE_WIKI_FLAG" = true ] && source $RESTORE_WIKI
[ "$FRESH_INSTALL_FLAG" = false ] && source $UPDATE_WIKI

echo "---=== [ READY! ] ===---" 
tail -f /data/logs/wiki.logs