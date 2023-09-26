#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
LOG_PATH=$SCRIPTS_PATH/configure_04-freedns.log
FREEDNS_CLIENT_SCRIPT=freeDNSupdateIP.sh




##--STEP#04 :: Configuring FreeDNS Client
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs started.." >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "" >> $LOG_PATH

echo '## Step01 - Checking FreeDNS API Client script..' >> $LOG_PATH
ls -ll $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT >> $LOG_PATH
echo '' >> $LOG_PATH
cat $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT >> $LOG_PATH
echo '' >> $LOG_PATH

echo '## Step02 - Executing script immediately..' >> $LOG_PATH
sudo chmod +x $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
$SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT
echo '' >> $LOG_PATH

echo '## Step03 - Adding script to crontab for onBoot execution..' >> $LOG_PATH
sudo crontab -l > crontab_root.backup
echo "PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin" >> cron_tmp
echo "@reboot sleep 60 ; $SCRIPTS_PATH/$FREEDNS_CLIENT_SCRIPT" >> cron_tmp
sudo crontab cron_tmp
rm cron_tmp
sudo service cron reload
sudo systemctl status cron | grep Active | awk '{$1=$1;print}' >> $LOG_PATH
sudo crontab -l | tail -n 2 >> $LOG_PATH
echo '' >> $LOG_PATH

echo '## Step04 - Show script log..' >> $LOG_PATH
cat $SCRIPTS_PATH/freeDNSupdateIP.log | tail -n 2


echo "" >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs done!" >> $LOG_PATH
