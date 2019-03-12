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
sudo echo "minion.sh has been executed last time on ${date}" |sudo tee $MAIN_DIR/logs/log
sudo echo "and will be installed under ${MAIN_DIR}\n"

source $MAIN_DIR/scripts/ovn_config.sh


sudo $MAIN_DIR/scripts/ovn_bootstrap.sh $MAIN_DIR >> $MAIN_DIR/logs/bootstrap_output
retval=$?
check_retval $retval


sudo $MAIN_DIR/scripts/minion/ovn_init_minion.sh $MINION_ID $MAIN_DIR >> $MAIN_DIR/logs/init_minion_output
retval=$?
check_retval $retval

sudo $MAIN_DIR/scripts/master/ovn_start_minion.sh $MINION_ID $MAIN_DIR >> $MAIN_DIR/logs/start_minion_output
retval=$?
check_retval $retval
