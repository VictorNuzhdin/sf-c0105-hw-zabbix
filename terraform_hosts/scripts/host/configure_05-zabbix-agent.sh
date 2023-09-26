#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
LOG_PATH=$SCRIPTS_PATH/configure_05-zabbix-agent.log





##--STEP#05 :: Installing Zabbix Agent
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs started.." >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "" >> $LOG_PATH


echo '## Installing Zabbix Agent v1 for Zabbix Server v6.4..' >> $LOG_PATH
sudo wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
sudo ls -ll >> $LOG_PATH
sudo dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
sudo apt update
sudo apt install -y zabbix-agent
echo "" >> $LOG_PATH

echo '## Starting and Enabling Zabbix Agent Service..' >> $LOG_PATH
sudo systemctl restart zabbix-agent
sudo systemctl enable zabbix-agent
echo "" >> $LOG_PATH

echo '## Checking Zabbix Agent installation..' >> $LOG_PATH
sudo systemctl status zabbix-agent | grep Active | awk '{$1=$1;print}' >> $LOG_PATH
sudo netstat -nltp4 | grep zabbix_agentd | awk '{print $1"  "$2"  "$3"  "$4"  "$5"  "$6"  "$7}' >> $LOG_PATH
echo "" >> $LOG_PATH

echo '## Adding new UFW Rule :: Allow Incoming TCP connections from Zabbix Server..' >> $LOG_PATH
sudo ufw allow 10050/tcp comment 'Allows Incoming conn from Zabbix Server'
sudo ufw status numbered >> $LOG_PATH
echo "" >> $LOG_PATH


echo "" >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs done!" >> $LOG_PATH
