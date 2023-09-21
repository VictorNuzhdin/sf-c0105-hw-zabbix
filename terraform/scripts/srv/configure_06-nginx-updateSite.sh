#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
CONFIGS_PATH=/home/ubuntu/scripts/configs/srv__v3_updateSite
LOG_PATH=$SCRIPTS_PATH/configure_06-nginx-updateSite.log
NEW_USER_LOGIN=devops
WEBSITE_DOMAIN_NAME=srv.dotspace.ru


##--STEP#06 :: Updating website html+css+js data..
##
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs started.." >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "" >> $LOG_PATH


echo '## Step06.1 - Removing old site data..' >> $LOG_PATH
sudo rm -rf /var/www/$WEBSITE_DOMAIN_NAME/html/*
echo "" >> $LOG_PATH

echo '## Step06.2 - Installing new site data..' >> $LOG_PATH
sudo cp $CONFIGS_PATH/index.html /var/www/$WEBSITE_DOMAIN_NAME/html/
sudo chown -R $NEW_USER_LOGIN:$NEW_USER_LOGIN /var/www/$WEBSITE_DOMAIN_NAME/html
sudo chmod -R 755 /var/www/$WEBSITE_DOMAIN_NAME
##..checkout
sudo ls -la /var/www/$WEBSITE_DOMAIN_NAME/html/ >> $LOG_PATH
echo "" >> $LOG_PATH
sudo tree /var/www/$WEBSITE_DOMAIN_NAME/html/ >> $LOG_PATH
echo "" >> $LOG_PATH

echo '## Step06.3 - Restarting nginx..' >> $LOG_PATH
##..restart nginx service
sudo systemctl restart nginx
##..checkout
sudo ls -1X $CONFIGS_PATH >> $LOG_PATH
sudo systemctl status nginx | grep Active | awk '{$1=$1;print}' >> $LOG_PATH
echo "" >> $LOG_PATH


sudo cp $CONFIGS_PATH/index.html /var/www/$WEBSITE_DOMAIN_NAME/html/
sudo chown -R $NEW_USER_LOGIN:$NEW_USER_LOGIN /var/www/$WEBSITE_DOMAIN_NAME/html
sudo chmod -R 755 /var/www/$WEBSITE_DOMAIN_NAME
echo "" >> $LOG_PATH





echo '## Step77 - Checking Nginx..' >> $LOG_PATH
echo $(nginx -V &> info && cat info | head -n 2 >> $LOG_PATH) && rm info

whereis nginx >> $LOG_PATH
systemctl status nginx | grep Active >> $LOG_PATH

echo ""
echo "" >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs done!" >> $LOG_PATH
