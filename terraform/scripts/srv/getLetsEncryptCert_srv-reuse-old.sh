#!/bin/bash

SCRIPTS_PATH=/home/ubuntu/scripts
CONFIGS_PATH=/home/ubuntu/scripts/configs/srv__v2_ssl
LETSENCRYPT_BACKUP_ARCHIVE=letsencrypt_backup_srv_20230918_114759.tar.gz
LOG_PATH=$SCRIPTS_PATH/getLetsEncryptCert_srv-reuse-old.log

##--parameters
WEBSITE_DOMAIN_NAME="srv.dotspace.ru"
WEBSITE_URL="https://$WEBSITE_DOMAIN_NAME"
WEBSITE_ADMIN_EMAIL=nuzhdin.vicx@yandex.ru


##..checking initial website availability | CORRECT_METHOD!
WEBSITE_STATUS=$(curl --silent --output /dev/null --write-out "%{http_code}" $WEBSITE_URL)

echo "DOMAIN_NAME...: $WEBSITE_DOMAIN_NAME"
echo "WEBSITE_URL...: $WEBSITE_URL"
echo "WEBSITE_STATUS: $WEBSITE_STATUS"
echo ""

## clear logfile
#sudo cat /dev/null > $LOG_PATH

##..if https site is available - exitting"
if [ "$WEBSITE_STATUS" = 200 ]; then
    echo '## Step05 - Obtaining an SSL Certificate (skipped)..'
    echo '## Step05 - Obtaining an SSL Certificate (skipped)..' >> $LOG_PATH
    ##..checkout
    ##  *output: <title>Welcome | srv.dotspace.ru</title>
    echo "$WEBSITE_URL"
    echo "$WEBSITE_URL" >> $LOG_PATH
    curl -s $WEBSITE_URL | grep title | awk '{$1=$1;print}'
    curl -s $WEBSITE_URL | grep title | awk '{$1=$1;print}' >> $LOG_PATH
    echo ""
    echo "" >> $LOG_PATH
    #
    exit 0
fi

##..if https site is NOT available - reuse/restore last ssl certificate"
if [[ "$WEBSITE_STATUS" != 200 ]]; then
    ## log2console + log2file
    echo '## Step05 - Obtaining an SSL Certificate (reuse/restore last certificate)..'
    echo '## Step05 - Obtaining an SSL Certificate (reuse/restore last certificate)..' >> $LOG_PATH
    ##..checkout (before)
    echo "..checkout (before)"
    echo "..checkout (before)" >> $LOG_PATH
    sudo ls -ll $CONFIGS_PATH/backups
    sudo ls -ll $CONFIGS_PATH/backups >> $LOG_PATH
    echo ""
    echo "" >> $LOG_PATH
    sudo cat /etc/letsencrypt
    sudo cat /etc/letsencrypt >> $LOG_PATH
    echo ""
    echo "" >> $LOG_PATH
    sudo ls /etc/nginx/sites-available/
    sudo ls /etc/nginx/sites-available/ >> $LOG_PATH
    echo ""
    echo "" >> $LOG_PATH
    sudo cat /etc/nginx/sites-available/$WEBSITE_DOMAIN_NAME
    sudo cat /etc/nginx/sites-available/$WEBSITE_DOMAIN_NAME >> $LOG_PATH
    echo ""
    echo "" >> $LOG_PATH
    sudo certbot --version
    sudo whereis certbot
    sudo certbot --version >> $LOG_PATH
    sudo whereis certbot >> $LOG_PATH
    echo ""
    echo "" >> $LOG_PATH
    sudo systemctl status nginx | grep Active | awk '{$1=$1;print}'
    sudo systemctl status nginx | grep Active | awk '{$1=$1;print}' >> $LOG_PATH
    echo ""
    echo "" >> $LOG_PATH
    echo http__status [$WEBSITE_DOMAIN_NAME]: $(curl --silent --output /dev/null --write-out "%{http_code}" http://$WEBSITE_DOMAIN_NAME)
    echo https_status [$WEBSITE_DOMAIN_NAME]: $(curl --silent --output /dev/null --write-out "%{http_code}" https://$WEBSITE_DOMAIN_NAME)
    echo http__status [$WEBSITE_DOMAIN_NAME]: $(curl --silent --output /dev/null --write-out "%{http_code}" http://$WEBSITE_DOMAIN_NAME) >> $LOG_PATH
    echo https_status [$WEBSITE_DOMAIN_NAME]: $(curl --silent --output /dev/null --write-out "%{http_code}" https://$WEBSITE_DOMAIN_NAME) >> $LOG_PATH
    echo ""
    echo "" >> $LOG_PATH
    ##
    ##..processing
    echo "..SSL_PROCESSING_START"
    echo "..SSL_PROCESSING_START" >> $LOG_PATH
    #sudo systemctl stop nginx
    sudo rm /etc/nginx/sites-available/$WEBSITE_DOMAIN_NAME
    sudo cp $CONFIGS_PATH/$WEBSITE_DOMAIN_NAME /etc/nginx/sites-available/
    sudo tar -xzvf $CONFIGS_PATH/backups/$LETSENCRYPT_BACKUP_ARCHIVE -C /
    ##
    sudo nginx -t
    sudo nginx -t >> $LOG_PATH
    sudo systemctl restart nginx
    echo "..SSL_PROCESSING_END"
    echo "..SSL_PROCESSING_END" >> $LOG_PATH
    echo ""
    echo "" >> $LOG_PATH
    ##
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
    #
    exit 0
fi
