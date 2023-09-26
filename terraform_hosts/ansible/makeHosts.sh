#!/bin/sh

## Ansible "hosts" file generator (dynamical inventory)
#
HOSTS_FILE=ansible/hosts

cat /dev/null > $HOSTS_FILE
#
echo "## generatedAt: $(date +'%Y-%m-%d %H:%M:%S')" >> $HOSTS_FILE
echo '#' >> $HOSTS_FILE
#
echo '[zabbix_server]' >> $HOSTS_FILE
echo 'localhost' >> $HOSTS_FILE
echo '' >> $HOSTS_FILE

echo '[zabbix_agents]' >> $HOSTS_FILE
##..generating with "Yandex Cloud CLI" (yc) and "Yandex Cloud API"
#yc compute instance-group list-instances --name ig-zabbix-fixed --format json | jq -r '.[].network_interfaces[].primary_v4_address.one_to_one_nat.address' >> $HOSTS_FILE
#
##..generating with "Json Query" (jq) and Terraform State
#cat terraform.tfstate | jq -r '.resources[0].instances[0].attributes.instances[].network_interface[0].nat_ip_address' >> $HOSTS_FILE
#
##..был создан "null_resource" поэтому идентификатор ресурcа в State изменился с [0] на [1] (видимо "null_resource" влез первым)
cat terraform.tfstate | jq -r '.resources[1].instances[0].attributes.instances[].network_interface[0].nat_ip_address' >> $HOSTS_FILE
echo '' >> $HOSTS_FILE

echo '[all:vars]' >> $HOSTS_FILE
echo 'ansible_ssh_pass=<SET_REMOTE_HOSTS_PASSWORD>' >> $HOSTS_FILE
