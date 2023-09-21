#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
LOG_PATH=$SCRIPTS_PATH/configure_04-freedns.log
FREEDNS_CLIENT_SCRIPT=freeDNSupdateIP.sh
FREEDNS_API_TOKEN='WymnCmqPTNNCrVkLzW6wnCPb'



##--STEP#77 :: Configuring FreeDNS Client
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs started.." >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "" >> $LOG_PATH

echo '## Step01 - Building API Client script..' >> $LOG_PATH
touch $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
chmod +x $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo '' >> $LOG_PATH

##-->start_script_body
echo '#!/bin/bash' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo '' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo '##=UPDATE CURRENT SERVER PUBLIC IP ADDRESS RECORD ON FreeDNS SERVICE (freedns.afraid.org)' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo '## *examples:' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo '##  curl -sk  "http://sync.afraid.org/u/<API_TOKEN>/?ip=<CURRENT_SERVER_PUBLIC_IPV4_ADRESS>"' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo '##  curl -sk "https://sync.afraid.org/u/<API_TOKEN>/?ip=<CURRENT_SERVER_PUBLIC_IPV4_ADRESS>"' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo '#' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo 'LOG_PATH=/home/ubuntu/scripts/freeDNSupdateIP.log' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo 'TS=$(echo `date +"%Y-%m-%d %H:%M:%S"`)' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo '' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo 'CURRENT_SERVER_PUBLIC_IPV4_ADRESS=$(curl -sk https://2ip.ru)' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo "API_TOKEN=$FREEDNS_API_TOKEN" >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo '' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo '' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo '##..do API request for update "srv.dotspace.ru" DNS-record' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo 'API_CALL_RESULT=$(curl -sk "https://sync.afraid.org/u/$API_TOKEN/?ip=$CURRENT_SERVER_PUBLIC_IPV4_ADRESS")' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo '' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo '##..log result' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo 'echo $TS -- $API_CALL_RESULT >> $LOG_PATH 2>/dev/null' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo '' >> $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
##<--end_script_body

echo '## Step02 - Adding script to crontab for onBoot execution..' >> $LOG_PATH
sudo crontab -l > crontab_root.backup
echo "PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin" >> cron_tmp
echo "@reboot sleep 60 ; $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT" >> cron_tmp
sudo crontab cron_tmp
rm cron_tmp
sudo service cron reload
sudo systemctl status cron | grep Active | awk '{$1=$1;print}' >> $LOG_PATH
sudo crontab -l | tail -n 2 >> $LOG_PATH
echo '' >> $LOG_PATH

echo '## Step03 - Execute script immediately..' >> $LOG_PATH
$SCRIPTS_PATH/freeDNSupdateIP.sh

echo '## Step04 - Show script log..' >> $LOG_PATH
cat $SCRIPTS_PATH/freeDNSupdateIP.log | tail -n 2


echo "" >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs done!" >> $LOG_PATH
