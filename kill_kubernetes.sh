#!/bin/bash

source ovn_config.sh

echo -ne "${orange}Stopping processes and deleting directories...${none}"
sudo pkill etcd
sudo pkill kube-apiserver
sudo pkill kube-controller-manager
sudo pkill kube-scheduler
sudo rm -rf /var/lib/etcd
sudo rm -rf /etc/kubernetes/manifests/*
sudo rm -rf $HOME/.kube
sudo rm -rf /var/log/openvswitch/ovnkube.log

for i in $(ps aux|grep -v grep|grep -v "kill_kubernetes"|grep kube|awk '{print $2}')
do
  kill -9 $i
done

# Uncomment this if everything needs to be made from scratch
# e.g., when new IP address has been assigned to the system as new
# certificates and other things should be regenerated
#sudo rm -rf /etc/kubernetes/*

echo -e "${green}[DONE]${none}"
