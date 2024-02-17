#!/bin/bash

# Run bluspice scripts 
echo "Starting bluspice"
php /data/www/bluespice/w/maintenance/update.php --quick
php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/initBackends.php --quick
php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/rebuildIndex.php --quick
php /data/www/bluespice/w/maintenance/runJobs.php --memory-limit=max --maxjobs=50

# Setup file permissions
/opt/docker/install-scripts/setwikiperm.sh /data/www/bluespice/w
