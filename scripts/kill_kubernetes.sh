#!/bin/bash

source ovn_config.sh
retval=$?
if [ $retval -ne 0 ]
then
  echo -e "Cannot include ovn_config.sh - maybe it is sourced from a wrong place!"
  exit -1
fi


echo -ne "${orange}Stopping processes...${none}"
sudo pkill etcd
sudo pkill kube-apiserver
sudo pkill kube-controller-manager
sudo pkill kube-scheduler
sudo service kubelet stop
sudo service docker stop

for i in $(ps aux|grep -v grep|grep -v "kill_kubernetes"|grep kube|awk '{print $2}')
do
  sudo kill -9 $i
done

echo -e "${green}[DONE]${none}"
