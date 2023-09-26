#!/bin/bash

##=UPDATE CURRENT SERVER PUBLIC IP ADDRESS RECORD ON FreeDNS SERVICE (freedns.afraid.org)
## *examples:
##  curl -sk  "http://sync.afraid.org/u/<API_TOKEN>/?ip=<CURRENT_SERVER_PUBLIC_IPV4_ADRESS>"
##  curl -sk "https://sync.afraid.org/u/<API_TOKEN>/?ip=<CURRENT_SERVER_PUBLIC_IPV4_ADRESS>"
#
SCRIPTS_PATH=/home/ubuntu/scripts
LOG_PATH=$SCRIPTS_PATH/freeDNSupdateIP.log

TS=$(echo `date +"%Y-%m-%d %H:%M:%S"`)

CURRENT_SERVER_HOSTNAME=$(hostname)
CURRENT_SERVER_PUBLIC_IPV4_ADRESS=$(curl -sk https://2ip.ru)

API_TOKEN=''
HOST1_FREEDNS_API_TOKEN='JXPcjcQJgPHDk7dUnz2TN3P4'
HOST2_FREEDNS_API_TOKEN='jHzwRrKMsd6XxKmpkWKun63U'

##..checking hostname and selecting appropriate token
if [[ "$CURRENT_SERVER_HOSTNAME" = "host1" ]]; then
    API_TOKEN=$HOST1_FREEDNS_API_TOKEN
fi
if [[ "$CURRENT_SERVER_HOSTNAME" = "host2" ]]; then
    API_TOKEN=$HOST2_FREEDNS_API_TOKEN
fi

##..do API request for update "hostX.dotspace.ru" DNS-record
API_CALL_RESULT=$(curl -sk "https://sync.afraid.org/u/$API_TOKEN/?ip=$CURRENT_SERVER_PUBLIC_IPV4_ADRESS")

##..log result
echo $TS -- $API_CALL_RESULT >> $LOG_PATH 2>/dev/null
