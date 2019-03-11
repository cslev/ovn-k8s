#!/bin/bash

source ovn_config.sh
retval=$?
if [ $retval -ne 0 ]
then
  echo -e "Cannot include ovn_config.sh - maybe it is sourced from a wrong place!"
  exit -1
fi

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
