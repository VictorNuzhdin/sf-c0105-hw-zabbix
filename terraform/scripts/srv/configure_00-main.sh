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
chmod +x $SCRIPTS_PATH/configure_04-freedns.sh
sudo bash $SCRIPTS_PATH/configure_04-freedns.sh
#
#..request NEW ssl certificate
#chmod +x $SCRIPTS_PATH/configure_05-ssl-letsencrypt-srv-request-new.sh
#sudo bash $SCRIPTS_PATH/configure_05-ssl-letsencrypt-srv-request-new.sh
#
#..reuse OLD ssl certificate
chmod +x $SCRIPTS_PATH/configure_05-ssl-letsencrypt-srv-reuse-old.sh
sudo bash $SCRIPTS_PATH/configure_05-ssl-letsencrypt-srv-reuse-old.sh
#
#..update website files
chmod +x $SCRIPTS_PATH/configure_06-nginx-updateSite.sh
sudo bash $SCRIPTS_PATH/configure_06-nginx-updateSite.sh
#
chmod +x $SCRIPTS_PATH/configure_66-firewall.sh
sudo bash $SCRIPTS_PATH/configure_66-firewall.sh
#
chmod +x $SCRIPTS_PATH/configure_99-getinfo.sh
sudo bash $SCRIPTS_PATH/configure_99-getinfo.sh
#
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Scripts execution done!" >> $LOG_PATH
