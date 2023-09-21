#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
LOG_PATH=$SCRIPTS_PATH/configure_99-getinfo.log
NEW_USER_LOGIN=devops




##--STEP#99 :: Collecting Configuration Info
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs started.." >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "" >> $LOG_PATH

echo "--VM was started and configured. Lets check configuration.." >> $LOG_PATH
echo "" >> $LOG_PATH

echo ":: host_ips" >> $LOG_PATH
curl -s 2ip.ru >> $LOG_PATH
hostname -I >> $LOG_PATH
echo "" >> $LOG_PATH

echo ":: user_id" >> $LOG_PATH
echo $(id devops) >> $LOG_PATH
echo "" >> $LOG_PATH

echo ":: sudoers_info" >> $LOG_PATH
sudo bash -c "tail -n 2 /etc/sudoers" >> $LOG_PATH
echo "" >> $LOG_PATH

echo ":: user_ssh_dir_permissions" >> $LOG_PATH
sudo ls -la /home/$NEW_USER_LOGIN/.ssh >> $LOG_PATH
echo "" >> $LOG_PATH

echo ":: user_ssh_keys" >> $LOG_PATH
sudo cat /home/$NEW_USER_LOGIN/.ssh/id_ed25519.pub >> $LOG_PATH
echo "" >> $LOG_PATH
sudo cat /home/$NEW_USER_LOGIN/.ssh/id_ed25519 >> $LOG_PATH
echo "" >> $LOG_PATH

echo ':: python_version'
##python --version >> $LOG_PATH           ## /tmp/configure_nginx.sh: 70: python: not found
python3 --version >> $LOG_PATH            ## Python 3.10.12

echo "" >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs done!" >> $LOG_PATH
