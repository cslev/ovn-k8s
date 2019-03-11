#!/bin/bash

# MAIN_DIR=$1
# if [ -z "$MAIN_DIR"  ]
# then
#   MAIN_DIR="/"
# fi
# if [ ! -d $MAIN_DIR ]
# then
#   echo -e "${MAIN_DIR} does not exist! Please specify properly as the first argument " \
#           "where you have downloaded the git repository ovn-k8s"
#   exit -1
# fi


sudo echo



#sudo git clone http://github.com/cslev/ovn-k8s
MAIN_DIR=$(pwd)
# sudo cd $MAIN_DIR
source $MAIN_DIR/scripts/ovn_config.sh



sudo $MAIN_DIR/scripts/ovn_bootstrap.sh $MAIN_DIR
retval=$?
check_retval $retval


sudo $MAIN_DIR/scripts/master/ovn_init_master.sh $MAIN_DIR
retval=$?
check_retval $retval

sudo $MAIN_DIR/scripts/master/ovn_start_master.sh $MAIN_DIR
retval=$?
check_retval $retval
