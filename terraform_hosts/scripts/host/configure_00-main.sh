#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
LOG_PATH=$SCRIPTS_PATH/configure_00-main.log





##--STEP#00 :: Execution of individual scripts
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Scripts execution started.." >> $LOG_PATH
#
#chmod -R +x $SCRIPTS_PATH
#
chmod +x $SCRIPTS_PATH/configure_01-users.sh
sudo bash $SCRIPTS_PATH/configure_01-users.sh
#
chmod +x $SCRIPTS_PATH/configure_02-packages.sh
sudo bash $SCRIPTS_PATH/configure_02-packages.sh
#
chmod +x $SCRIPTS_PATH/configure_03-nginx.sh
sudo bash $SCRIPTS_PATH/configure_03-nginx.sh
#
#..update website files
#chmod +x $SCRIPTS_PATH/configure_06-nginx-updateSite.sh
#sudo bash $SCRIPTS_PATH/configure_06-nginx-updateSite.sh
#
chmod +x $SCRIPTS_PATH/configure_66-firewall.sh
sudo bash $SCRIPTS_PATH/configure_66-firewall.sh
#
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Scripts execution done!" >> $LOG_PATH
