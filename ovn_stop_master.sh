#!/bin/bash

source ovn_config.sh
source master_args.sh

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
