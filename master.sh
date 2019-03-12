#!/bin/bash

MAIN_DIR=$1
if [ -z "$MAIN_DIR"  ]
then
  MAIN_DIR="/local/repository"
fi
if [ ! -d $MAIN_DIR ]
then
  sudo mkdir -p $MAIN_DIR
fi

sudo echo

sudo mkdir -p $MAIN_DIR/logs
cd $MAIN_DIR

#sudo git clone http://github.com/cslev/ovn-k8s
#MAIN_DIR=$(pwd)
date=$(date)
sudo echo -e "master.sh has been executed last time on ${date}" |sudo tee $MAIN_DIR/logs/log
sudo echo -e "and will be installed under ${MAIN_DIR}\n" | sudo tee -a $MAIN_DIR/logs/log


source $MAIN_DIR/scripts/ovn_config.sh



sudo $MAIN_DIR/scripts/ovn_bootstrap.sh $MAIN_DIR | sudo tee $MAIN_DIR/logs/bootstrap_output
retval=$?
check_retval $retval


sudo $MAIN_DIR/scripts/master/ovn_init_master.sh $MAIN_DIR | sudo tee $MAIN_DIR/logs/init_master_output
retval=$?
check_retval $retval

sudo $MAIN_DIR/scripts/master/ovn_start_master.sh $MAIN_DIR |sudo tee $MAIN_DIR/logs/start_master_output
retval=$?
check_retval $retval
