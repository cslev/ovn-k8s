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

echo -ne "${orange}Stopping processes and deleting directories...${none}"
sudo pkill ovs-vswitchd
sudo pkill ovsdb-server
sudo pkill ovsdb-server
sudo pkill ovn-northd
sudo pkill ovn-controller
sudo rm -rf $OVN_PID_DIR
sudo rm -rf $OVN_DB_FILE_DIR
sudo rm -rf $OVN_LOG_DIR
sudo rm -rf $OVN_SOCKET_DIR
sudo rm -rf /var/run/openvswitch/
t=$(sudo ovs-dpctl show)
if [[ ! -z "$t" ]]
then
  sudo ovs-dpctl del-dp ovs-system
fi
echo -e "${green}[DONE]${none}"
