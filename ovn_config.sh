#!/bin/bash

OVERLAY_IP=10.10.0.11
LOCAL_IP=$OVERLAY_IP
CENTRAL_IP=$OVERLAY_IP
POD_IP_RANGE=192.168.0.0/16
SERVICE_IP_RANGE=172.16.1.0/24
NODE_NAME=k8s-master

GOPATH=/home/csikor/ovn-k8s/
PATH=$PATH:$GOPATH/go/bin/
PATH=$PATH:/usr/local/share/openvswitch/scripts


# Default directories ovn-ctl script looks for
OVN_LOG_DIR=/usr/local/var/log/openvswitch
OVN_PID_DIR=/usr/local/var/run/openvswitch
OVN_SOCKET_DIR=/usr/local/var/run/openvswitch
OVN_DB_FILE_DIR=/usr/local/etc/openvswitch
OVN_DB_SCHEMA_DIR=/usr/local/share/openvswitch
OVN_CTL=/usr/local/share/openvswitch/scripts/ovn-ctl

#COLORIZING
none='\033[0m'
bold='\033[01m'
disable='\033[02m'
underline='\033[04m'
reverse='\033[07m'
strikethrough='\033[09m'
invisible='\033[08m'

black='\033[30m'
red='\033[31m'
green='\033[32m'
orange='\033[33m'
blue='\033[34m'
purple='\033[35m'
cyan='\033[36m'
lightgrey='\033[37m'
darkgrey='\033[90m'
lightred='\033[91m'
lightgreen='\033[92m'
yellow='\033[93m'
lightblue='\033[94m'
pink='\033[95m'
lightcyan='\033[96m'

