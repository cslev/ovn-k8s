#!/bin/bash

MINION_ID=$1
MAIN_DIR=$2
if [ -z "$MAIN_DIR"  ]
then
  MAIN_DIR="/local/repository"
fi
if [ ! -d $MAIN_DIR ]
then
  sudo mkdir -p $MAIN_DIR
fi

cd $MAIN_DIR
if [ -z "$MINION_ID" ]
then
  echo -e "${red}MINION_ID as second argument has not been defined! Use 1,2,...,n for setting it properly"
  exit -1
fi


sudo echo
sudo mkdir -p $MAIN_DIR/logs


# sudo git clone http://github.com/cslev/ovn-k8s
date=$(date)
sudo echo -e "minion.sh has been executed last time on ${date}" |sudo tee $MAIN_DIR/logs/log
sudo echo -e "and will be installed under ${MAIN_DIR}\n" |sudo tee -a $MAIN_DIR/logs/log

source $MAIN_DIR/scripts/ovn_config.sh

sudo echo -e "\n\n${reverse}${red}" \
"+---------------------------------------------------------+ \n" \
"|   OVN-K8S minion ${MINION_ID} installation is still in progress !  | \n" \
"|                PLEASE WAIT OR GET BACK LATER!           | \n" \
"+---------------------------------------------------------+ ${disable}${none}" | sudo tee  /etc/motd

sudo $MAIN_DIR/scripts/ovn_bootstrap.sh $MAIN_DIR |sudo tee $MAIN_DIR/logs/bootstrap_output
retval=$?
check_retval $retval


sudo $MAIN_DIR/scripts/minion/ovn_init_minion.sh $MINION_ID $MAIN_DIR | sudo tee $MAIN_DIR/logs/init_minion_output
retval=$?
check_retval $retval

sudo $MAIN_DIR/scripts/minion/ovn_start_minion.sh $MINION_ID $MAIN_DIR | sudo tee $MAIN_DIR/logs/start_minion_output
retval=$?
check_retval $retval

sudo echo -e "\n\n${reverse}${green}" \
"+-------------------------------------------------------------------+ \n" \
"|   OVN-K8S minion ${MINION_ID} installation has been completed !              | \n" \
"|                            Check logs!                            | \n" \
"| Check status @master via:                                         | \n" \
"| sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes    | \n" \
"+-------------------------------------------------------------------+ ${disable}${none}" | sudo tee  /etc/motd
