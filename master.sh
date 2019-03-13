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


sudo echo -e "\n\n${reverse}${red}" \
"+-------------------------------------------------------+ \n" \
"|   OVN-K8S master installation is still in progress !  | \n" \
"|      PLEASE WAIT and CHECK LOGS FOR MORE DETAILS!     | \n" \
"|  OR IT IS PREFERABLE TO LOGOUT AND LOGIN BACK LATER   | \n" \
"|               UNTIL THIS MESSAGE DISAPPEARS           | \n" \
"+-------------------------------------------------------+ ${disable}${none}" | sudo tee  /etc/motd


sudo $MAIN_DIR/scripts/ovn_bootstrap.sh $MAIN_DIR | sudo tee $MAIN_DIR/logs/bootstrap_output
retval=$?
check_retval $retval
echo "ovn_bootstrap.sh has successfully finished!" | sudo tee -a $MAIN_DIR/logs/log


sudo $MAIN_DIR/scripts/master/ovn_init_master.sh $MAIN_DIR | sudo tee $MAIN_DIR/logs/init_master_output
retval=$?
check_retval $retval
echo "ovn_init_master.sh has successfully finished!" | sudo tee -a $MAIN_DIR/logs/log

sudo $MAIN_DIR/scripts/master/ovn_start_master.sh $MAIN_DIR |sudo tee $MAIN_DIR/logs/start_master_output &
retval=$?
check_retval $retval
echo "ovn_start_master.sh has successfully finished!" | sudo tee -a $MAIN_DIR/logs/log


sudo echo -e "\n\n${reverse}${green}" \
"+-----------------------------------------------------------------+ \n" \
"|   OVN-K8S master installation has been completed !              | \n" \
"|                            Check logs!                          | \n" \
"| Check status via:                                               | \n" \
"| sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes  | \n" \
"+-----------------------------------------------------------------+ ${disable}${none}" | sudo tee  /etc/motd
