#!/bin/bash

GOPATH=/usr/local
sudo mkdir -p /usr/local
#add GOPATH to PATH
PATH=$PATH:$GOPATH/go/bin
#add ovn-ctl
OVN_CTL_PATH=/usr/local/share/openvswitch/scripts
PATH=$PATH:$OVN_CTL_PATH

#add emulab to path (for cloudlab)
EMULAB=/usr/local/etc/emulab
PATH=$PATH:$EMULAB

# Default directories ovn-ctl script looks for
OVN_LOG_DIR=/usr/local/var/log/openvswitch
OVN_PID_DIR=/usr/local/var/run/openvswitch
OVN_SOCKET_DIR=/usr/local/var/run/openvswitch
OVN_DB_FILE_DIR=/usr/local/etc/openvswitch
OVN_DB_SCHEMA_DIR=/usr/local/share/openvswitch
OVN_CTL=$OVN_CTL_PATH/ovn-ctl

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

#check whether ovnkube is in the path variable and can be executed
which ovnkube
retval=$?
if [ retval -ne 0 ]
then
  echo -e "${yellow}ovnkube binary cannot be reached..."
  echo -e "Falling back to compiled path (${MAIN_DIR}/ovn-kubernetes/go-controller/_output/go/bin/ovnkube)"
  OVNKUBE_PATH=$MAIN_DIR/ovn-kubernetes/go-controller/_output/go/bin/ovnkube
else
  OVNKUBE_PATH=$(which ovnkube)
fi

check_retval ()
{
  retval=$1
  if [ $retval -ne 0 ]
  then
    echo -e "${bold}${red}Something went wrong during the installation process..."
    echo -e "EXITING${none}"
    exit -1
  else
    echo -e "${green}[DONE]${none}"
  fi

}
