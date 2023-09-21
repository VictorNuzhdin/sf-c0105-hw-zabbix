#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
LOG_PATH=$SCRIPTS_PATH/configure_66-firewall.log





##--STEP#66 :: Enabling and Configuring build-in Ubuntu 22.04 firewall (ufw)
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs started.." >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "" >> $LOG_PATH

echo '## Step00.1 - Set default ruleset..' >> $LOG_PATH
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo '## Step00.2 - Disable IPv6 processing/rules..' >> $LOG_PATH
sudo cat /etc/default/ufw | grep "IPV6=" >> $LOG_PATH
sudo sed -i 's/IPV6=yes/IPV6=no/g' /etc/default/ufw
sudo cat /etc/default/ufw | grep "IPV6=" >> $LOG_PATH
echo "" >> $LOG_PATH

echo '## Step01 - Allow incoming SSH..' >> $LOG_PATH
#sudo ufw allow 'OpenSSH'
sudo ufw allow 22

echo '## Step02 - Allow incoming HTTP/S for Apache/Nginx web servers..' >> $LOG_PATH
#sudo ufw allow 'Nginx HTTP'
#sudo ufw allow 'Nginx HTTPS'
sudo ufw allow 80
sudo ufw allow 443

echo '## Step66 - Enabling firewall..' >> $LOG_PATH
#sudo ufw enable        ## Stupid interactive warning: Command may disrupt existing ssh connections. Proceed with operation (y|n)?
ufw --force enable
echo "" >> $LOG_PATH

echo '## Step77 - Getting firewall status..' >> $LOG_PATH
sudo ufw status >> $LOG_PATH
echo "" >> $LOG_PATH

echo "" >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs done!" >> $LOG_PATH
