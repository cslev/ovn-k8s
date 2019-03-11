#!/bin/bash
OVERLAY_IP=10.10.0.13
LOCAL_IP=$OVERLAY_IP
CENTRAL_IP=10.10.0.11
POD_IP_RANGE=192.168.0.0/16
SERVICE_IP_RANGE=172.16.1.0/24
NODE_NAME=k8s-minion2

IFNAME=$(ifconfig |grep -B 1 $LOCAL_IP | grep -v $LOCAL_IP|cut -d ':' -f1)
GW_IP=$(route -n |grep $IFNAME|grep 0.0.0.0 |grep -v 255.255|awk '{print $2}')
