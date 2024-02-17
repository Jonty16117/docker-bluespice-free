#!/bin/bash

rm -Rf /data/www/bluespice/w/images
echo "Importing the data from the old installation"
cp -Rf /data/backups/$CURR_TIMESTAMP/w/images /data/www/bluespice/w/images 

echo "copying bluespice foundation data folders..." 
mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/data 
cp -rf /data/backups/$CURR_TIMESTAMP/w/extensions/BlueSpiceFoundation/data/. /data/www/bluespice/w/extensions/BlueSpiceFoundation/data/ 
echo "copied bluespice foundation data folders" 

cp -f /data/backups/$CURR_TIMESTAMP/w/LocalSettings.php /data/www/bluespice/w/ 

# restore local settings from old wiki
# echo "copying local settings from old wiki" 
# cp -f /data/backups/$CURR_TIMESTAMP/w/settings.d/*.local.php /data/www/bluespice/w/settings.d/ 
# echo "copied local settings from old wiki" 
