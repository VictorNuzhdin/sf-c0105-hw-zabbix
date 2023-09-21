#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
CONFIGS_PATH=/home/ubuntu/scripts/configs/srv__v1_init
LOG_PATH=$SCRIPTS_PATH/configure_03-nginx.log
NEW_USER_LOGIN=devops
WEBSITE_DOMAIN_NAME=srv.dotspace.ru


##--STEP#03 :: Installing Nginx and Configuring default website ($WEBSITE_DOMAIN_NAME)
##  https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-22-04
##  https://www.digitalocean.com/community/tutorials/how-to-configure-jenkins-with-ssl-using-an-nginx-reverse-proxy-on-ubuntu-22-04
##
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs started.." >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "" >> $LOG_PATH

echo '## Step01 - Installing Nginx..' >> $LOG_PATH
sudo apt install -y nginx
echo "" >> $LOG_PATH

echo '## Step02 - Configuring default site..' >> $LOG_PATH
##..creating site-root directory, placing index.html, change perms
sudo mkdir -p /var/www/$WEBSITE_DOMAIN_NAME/html
sudo cp $CONFIGS_PATH/index.html /var/www/$WEBSITE_DOMAIN_NAME/html/
sudo chown -R $NEW_USER_LOGIN:$NEW_USER_LOGIN /var/www/$WEBSITE_DOMAIN_NAME/html
sudo chmod -R 755 /var/www/$WEBSITE_DOMAIN_NAME
ls -la /var/www/$WEBSITE_DOMAIN_NAME >> $LOG_PATH
echo "" >> $LOG_PATH
cat /var/www/$WEBSITE_DOMAIN_NAME/html/index.html | grep title | awk '{$1=$1;print}' >> $LOG_PATH
echo "" >> $LOG_PATH
##..disabling "default" site config and enabling new site config
sudo rm /etc/nginx/sites-enabled/default
sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default_backup
sudo cp $CONFIGS_PATH/$WEBSITE_DOMAIN_NAME /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/$WEBSITE_DOMAIN_NAME /etc/nginx/sites-enabled/
##..make some nginx conf memory tricks
##  *enable "server_names_hash_bucket_size 64;" option in /etc/nginx/nginx.conf
sudo sed -i 's/# server_names_hash_bucket_size 64;/server_names_hash_bucket_size 64;/g' /etc/nginx/nginx.conf
##..restart nginx service
sudo systemctl restart nginx
##..checkout
sudo ls -1X $CONFIGS_PATH >> $LOG_PATH
echo "" >> $LOG_PATH
sudo systemctl status nginx | grep Active | awk '{$1=$1;print}' >> $LOG_PATH
echo "" >> $LOG_PATH
sudo nginx -t >> $LOG_PATH
echo "" >> $LOG_PATH
sudo ls -la /etc/nginx/sites-available >> $LOG_PATH
echo "" >> $LOG_PATH
sudo ls -la /etc/nginx/sites-enabled >> $LOG_PATH
echo "" >> $LOG_PATH
##..site is not available immediately after VM is created (only after 5 minutes)
#host gw2.dotspace.ru >> $LOG_PATH
#curl -s http://srv.dotspace.ru | grep title | awk '{$1=$1;print}' >> $LOG_PATH
##..checks site by current ipv4 address of current server
echo "[$WEBSITE_DOMAIN_NAME] ($(curl -s 2ip.ru))" >> $LOG_PATH
curl -s $(curl -s 2ip.ru) | grep title | awk '{$1=$1;print}' >> $LOG_PATH
echo "" >> $LOG_PATH


echo '## Step77 - Checking Nginx..' >> $LOG_PATH
echo $(nginx -V &> info && cat info | head -n 2 >> $LOG_PATH) && rm info

whereis nginx >> $LOG_PATH
systemctl status nginx | grep Active >> $LOG_PATH

echo ""
echo "" >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs done!" >> $LOG_PATH
