#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
LOG_PATH=$SCRIPTS_PATH/configure_05-ssl-letsencrypt-srv-request-new.log

WEBSITE_DOMAIN_NAME="srv.dotspace.ru"



##--STEP#05 :: Configuring HTTPS/SSL with "Lets Encrypt" (requesting NEW certificate)
##  https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-22-04
##
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs started.." >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "" >> $LOG_PATH


echo '## Step01 - Installing Certbot..' >> $LOG_PATH
sudo snap install core && sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
##..checkout
snap list | grep core | head -n 1 >> $LOG_PATH
snap list | grep certbot >> $LOG_PATH
sudo ls -ll /usr/bin/certbot >> $LOG_PATH
echo "" >> $LOG_PATH

echo '## Step02 - Confirming Nginx Configuration (skipped)..' >> $LOG_PATH
##..checkout
sudo cat /etc/nginx/sites-available/$WEBSITE_DOMAIN_NAME | grep server_name | awk '{$1=$1;print}' >> $LOG_PATH
echo "" >> $LOG_PATH

echo '## Step03 - Allowing HTTPS through firewall (skipped)..' >> $LOG_PATH
##..checkout
sudo ufw status >> $LOG_PATH
echo "" >> $LOG_PATH


echo '## Step04 - Obtaining an SSL Certificate (running external script)..' >> $LOG_PATH
##..obtaining cert (inline)
#sudo certbot --nginx -d srv.dotspace.ru --non-interactive --agree-tos -m nuzhdin.vicx@yandex.ru
#sudo certbot --nginx -d $WEBSITE_DOMAIN_NAME --non-interactive --agree-tos -m $WEBSITE_ADMIN_EMAIL
#
##..obtaining cert (with script)
chmod +x $SCRIPTS_PATH/getLetsEncryptCert_srv-request-new.sh
sudo bash $SCRIPTS_PATH/getLetsEncryptCert_srv-request-new.sh
#
##..checkout (after)
## log2console
echo ""
echo "https://$WEBSITE_DOMAIN_NAME"
curl -s https://$WEBSITE_DOMAIN_NAME | grep title | awk '{$1=$1;print}'
echo ""
## log2file
echo "https://$WEBSITE_DOMAIN_NAME" >> $LOG_PATH
curl -s https://$WEBSITE_DOMAIN_NAME | grep title | awk '{$1=$1;print}' >> $LOG_PATH
echo "" >> $LOG_PATH

echo "" >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs done!" >> $LOG_PATH
