#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
LOG_PATH=$SCRIPTS_PATH/configure_05-ssl-letsencrypt-srv-reuse-old.log

WEBSITE_DOMAIN_NAME="srv.dotspace.ru"



##--STEP#05 :: Configuring HTTPS/SSL with "Lets Encrypt" (reusing OLD/last certificate)
##  https://community.letsencrypt.org/t/how-to-backup-and-restore-lets-encrypt-ubuntu-server/39617
##  https://community.letsencrypt.org/t/hi-i-need-make-backup-something-for-lets-encrypt-to-make-a-install-new-of-server-ubuntu/184494
##  https://community.letsencrypt.org/t/migrate-certificates-and-settings-from-one-server-to-another/176615
##  https://community.letsencrypt.org/t/best-way-to-backup-letsencrypt-folder/21551
##  https://blog.adriaan.io/how-to-copy-letsencrypt-account-including-all-certificates-to-a-new-server.html
##  https://github.com/AlexWinder/letsencrypt-backup
##  https://blomsmail.medium.com/how-to-reuse-a-lets-encrypt-certificate-on-a-new-server-19e7224e4d81
##
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs started.." >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "" >> $LOG_PATH


echo '## Step01 - Installing Certbot..'
echo '## Step01 - Installing Certbot..' >> $LOG_PATH
sudo snap install core && sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
##..checkout
snap list | grep core | head -n 1 >> $LOG_PATH
snap list | grep certbot >> $LOG_PATH
sudo ls -ll /usr/bin/certbot >> $LOG_PATH
echo "" >> $LOG_PATH

echo '## Step02 - Confirming Nginx Configuration (skipped)..'
echo '## Step02 - Confirming Nginx Configuration (skipped)..' >> $LOG_PATH
##..checkout
sudo cat /etc/nginx/sites-available/$WEBSITE_DOMAIN_NAME | grep server_name | awk '{$1=$1;print}' >> $LOG_PATH
echo "" >> $LOG_PATH

echo '## Step03 - Allowing HTTPS through firewall (skipped)..'
echo '## Step03 - Allowing HTTPS through firewall (skipped)..' >> $LOG_PATH
##..checkout
sudo ufw status >> $LOG_PATH
echo "" >> $LOG_PATH

echo '## Step04 - Obtaining an SSL Certificate (running external script)..'
echo '## Step04 - Obtaining an SSL Certificate (running external script)..' >> $LOG_PATH
##..obtaining old/last cert (with script)
chmod +x $SCRIPTS_PATH/getLetsEncryptCert_srv-reuse-old.sh
sudo bash $SCRIPTS_PATH/getLetsEncryptCert_srv-reuse-old.sh
echo ""
echo "" >> $LOG_PATH

echo '## Step05 - Final checkout..'
echo '## Step05 - Final checkout..' >> $LOG_PATH
##..checkout (after)
echo "..checkout (after)"
echo "..checkout (after)" >> $LOG_PATH
sudo systemctl status nginx | grep Active | awk '{$1=$1;print}'
sudo systemctl status nginx | grep Active | awk '{$1=$1;print}' >> $LOG_PATH
echo ""
echo "" >> $LOG_PATH
sudo cat /etc/nginx/sites-available/$WEBSITE_DOMAIN_NAME | grep letsencrypt | awk '{$1=$1;print}'
sudo cat /etc/nginx/sites-available/$WEBSITE_DOMAIN_NAME | grep letsencrypt | awk '{$1=$1;print}' >> $LOG_PATH
echo ""
echo "" >> $LOG_PATH
echo http__status [$WEBSITE_DOMAIN_NAME]: $(curl --silent --output /dev/null --write-out "%{http_code}" http://$WEBSITE_DOMAIN_NAME)
echo https_status [$WEBSITE_DOMAIN_NAME]: $(curl --silent --output /dev/null --write-out "%{http_code}" https://$WEBSITE_DOMAIN_NAME)
echo http__status [$WEBSITE_DOMAIN_NAME]: $(curl --silent --output /dev/null --write-out "%{http_code}" http://$WEBSITE_DOMAIN_NAME) >> $LOG_PATH
echo https_status [$WEBSITE_DOMAIN_NAME]: $(curl --silent --output /dev/null --write-out "%{http_code}" https://$WEBSITE_DOMAIN_NAME) >> $LOG_PATH


echo ""
echo "" >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs done!" >> $LOG_PATH
