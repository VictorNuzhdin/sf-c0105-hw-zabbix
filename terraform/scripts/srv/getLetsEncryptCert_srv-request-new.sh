#!/bin/bash

SCRIPTS_PATH=/home/ubuntu/scripts
LOG_PATH=$SCRIPTS_PATH/getLetsEncryptCert_srv-request-new.log

##--parameters
WEBSITE_DOMAIN_NAME="srv.dotspace.ru"
WEBSITE_URL="http://$WEBSITE_DOMAIN_NAME"
WEBSITE_ADMIN_EMAIL=nuzhdin.vicx@yandex.ru

##--limits
CHECK_INTERVAL=10
CHECK_ATTEMPTS=40
CHECK_TIME_LIMIT=600

echo "DOMAIN_NAME..: $WEBSITE_DOMAIN_NAME"
echo "MAX_ATTEMPTS.: $CHECK_ATTEMPTS"
echo "MAX_TIME(sec): $CHECK_TIME_LIMIT"
echo "INTERVAL(sec): $CHECK_INTERVAL"
echo ""

##..checking initial website availability | WRONG_METHOD!
## WEBSITE_STATUS="$(curl -sI $WEBSITE_URL | head -n 1 | cut -d $' ' -f2)"

##..checking initial website availability | CORRECT_METHOD!
WEBSITE_STATUS=$(curl --silent --output /dev/null --write-out "%{http_code}" $WEBSITE_URL)

##--checking website availability (pseudo-infinity loop with time and attempts limits)
ATTEMPTS_COUNTER=1

##..if site is online - request LetsEncrypt certificate with "certbot"
if [ "$WEBSITE_STATUS" = 200 ]; then
    echo "$WEBSITE_URL :: 200 :: ONLINE ($(host $WEBSITE_DOMAIN_NAME | awk '{ print $4 }'))"
    #
    echo '## Step05 - Obtaining an SSL Certificate..' >> $LOG_PATH
    sudo certbot --nginx -d $WEBSITE_DOMAIN_NAME --non-interactive --agree-tos -m $WEBSITE_ADMIN_EMAIL > $LOG_PATH
    echo "" >> $LOG_PATH
    ##..checkout (after)
    ##  *output: <title>Welcome | gw.dotspace.ru</title>
    echo "https://$WEBSITE_DOMAIN_NAME"
    echo "https://$WEBSITE_DOMAIN_NAME" >> $LOG_PATH
    curl -s https://$WEBSITE_DOMAIN_NAME | grep title | awk '{$1=$1;print}'
    curl -s https://$WEBSITE_DOMAIN_NAME | grep title | awk '{$1=$1;print}' >> $LOG_PATH
    echo ""
    echo "" >> $LOG_PATH
    #
    exit 0
fi

##..if site is offline - checks again and again till limits are triggered
if [[ "$WEBSITE_STATUS" != 200 ]]; then

    STARTED=`date +%s`

    while ((STARTED + $CHECK_TIME_LIMIT > `date +%s`));
    do
        ##..checking website availability
        WEBSITE_STATUS=$(curl --silent --output /dev/null --write-out "%{http_code}" $WEBSITE_URL)

        if [[ "$ATTEMPTS_COUNTER" = "$CHECK_ATTEMPTS" ]]; then
            echo "Max attempts limit occured! exiting.."
            echo "Max attempts limit occured! exiting.." >> $LOG_PATH
            echo ""
            echo "" >> $LOG_PATH
            exit 1
        fi

        if [[ "$WEBSITE_STATUS" = 200 ]]; then
            echo "$WEBSITE_URL :: 200 :: ONLINE ($(host $WEBSITE_DOMAIN_NAME | awk '{ print $4 }'))"
            #
            echo '## Step05 - Obtaining an SSL Certificate..' >> $LOG_PATH
            sudo certbot --nginx -d $WEBSITE_DOMAIN_NAME --non-interactive --agree-tos -m $WEBSITE_ADMIN_EMAIL > $LOG_PATH
            ##..checkout (after)
            ##  *output: <title>Welcome | srv.dotspace.ru</title>
            echo "https://$WEBSITE_DOMAIN_NAME"
            echo "https://$WEBSITE_DOMAIN_NAME" >> $LOG_PATH
            curl -s https://$WEBSITE_DOMAIN_NAME | grep title | awk '{$1=$1;print}'
            curl -s https://$WEBSITE_DOMAIN_NAME | grep title | awk '{$1=$1;print}' >> $LOG_PATH
            echo "" >> $LOG_PATH
            #
            echo ""
            exit 0
            else
               echo "$WEBSITE_URL :: OFFLINE ($ATTEMPTS_COUNTER) -- $(date +'%H:%M:%S')"
               echo "$WEBSITE_URL :: OFFLINE ($ATTEMPTS_COUNTER) -- $(date +'%H:%M:%S')" >> $LOG_PATH
               let "ATTEMPTS_COUNTER++"
        fi
        sleep $CHECK_INTERVAL
    done
    echo "Time limit occured! exiting.."
    echo "Time limit occured! exiting.." >> $LOG_PATH
    echo ""
    echo "" >> $LOG_PATH
fi
echo ""
echo "" >> $LOG_PATH
