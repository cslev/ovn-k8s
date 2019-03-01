#!/bin/bash

source ovn_config.sh
source minion1_args.sh

echo -ne "${orange}Stopping processes and deleting directories...${none}"
sudo pkill ovs-vswitchd
sudo pkill ovsdb-server
sudo pkill ovsdb-server
sudo pkill ovn-northd
sudo pkill ovn-controller
sudo pkill ovnkube
sudo rm -rf $OVN_PID_DIR
sudo rm -rf $OVN_DB_FILE_DIR
sudo rm -rf $OVN_LOG_DIR
sudo rm -rf $OVN_SOCKET_DIR
sudo rm -rf /var/run/openvswitch/
ovs-dpctl del-dp ovs-system
echo -e "${green}[DONE]${none}"
