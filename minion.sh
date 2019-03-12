#!/bin/bash

MINION_ID=$1
# MAIN_DIR=$2
#
# if [ -z "$MAIN_DIR"  ]
# then
#   MAIN_DIR="/"
# fi
# if [ -d $MAIN_DIR ]
# then
#   echo -e "${MAIN_DIR} does not exist! Please specify properly as the first argument " \
#           "where you have downloaded the git repository ovn-k8s"
#   exit -1
# fi

if [ -z "$MINION_ID" ]
then
  echo -e "${red}MINION_ID as second argument has not been defined! Use 1,2,...,n for setting it properly"
  exit -1
fi

sudo echo

# sudo cd $MAIN_DIR

# sudo git clone http://github.com/cslev/ovn-k8s
MAIN_DIR=$(pwd)
date=$(date)
sudo echo "master.sh has been executed last time on ${date}" >> $MAIN_DIR/log
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
