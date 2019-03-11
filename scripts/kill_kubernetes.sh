#!/bin/bash
MAIN_DIR=$1

if [ -z "$MAIN_DIR"  ]
then
  MAIN_DIR=$(pwd)
fi

#if MAIN_DIR was set but it does not exist!
if [[ ! -d $MAIN_DIR ]]
then
  echo -e "${MAIN_DIR} does not exist! Please specify properly as the first" \
          "argument where you have downloaded the git repository ovn-k8s!"
  exit -1
fi

source $MAIN_DIR/ovn_config.sh

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
