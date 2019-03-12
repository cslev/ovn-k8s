#!/bin/bash

#this script initializes the kubernetes and docker background for OVN-KUBERNETES
MINION_ID=$1
MAIN_DIR=$2

if [ -z "$MAIN_DIR"  ]
then
  MAIN_DIR=$(pwd)
fi

#if MAIN_DIR was set but it does not exist!
if [[ ! -d $MAIN_DIR ]]
then
  echo -e "${MAIN_DIR} does not exist! Please specify properly as the first" \
          "argument where you have downloaded the git repository ovn-k8s!"
  exit -1
fi

source $MAIN_DIR/scripts/ovn_config.sh

if [ -z "$MINION_ID" ]
then
  echo -e "${red}MINION_ID as second argument has not been defined! Use 1,2,...,n for setting it properly"
  exit -1
fi
source $MAIN_DIR/scripts/minion/minion${MINION_ID}_args.sh


sudo echo

echo -e "${orange}Setting up hostname and hosts aliases...${orange}"
sudo echo "127.0.0.1   ${NODE_NAME}  localhost" | sudo tee /etc/hosts
sudo echo "${CENTRAL_IP}  k8s-master" | sudo tee -a /etc/hosts
sudo echo "${OVERLAY_IP}  ${NODE_NAME}"| sudo tee -a /etc/hosts
sudo echo $NODE_NAME | sudo tee /etc/hostname
sudo hostname -F /etc/hostname


sudo $MAIN_DIR/scripts/kill_kubernetes.sh

echo -ne "${orange}Removing previous attempts' gargabe...${none}"
sudo rm -rf /var/lib/etcd
sudo rm -rf /etc/kubernetes/manifests/*
sudo rm -rf $HOME/.kube
sudo rm -rf /etc/kubernetes/kubelet.conf
sudo rm -rf /etc/kubernetes/bootstrap-kubelet.conf
sudo rm -rf /etc/kubernetes/pki/ca.crt
echo -e "${green}[DONE]${none}"

echo -ne "${orange}Stopping KUBELET service...${none}"
sudo service kubelet stop
echo -e "${green}[DONE]${none}"


echo -ne "${orange}Stopping DOCKER service...${none}"
sudo service docker stop
echo -e "${green}[DONE]${none}"



echo -ne "${orange}Starting DOCKER service...${none}"
sudo service docker start
echo -e "${green}[DONE]${none}"

echo -ne "${orange}Disabling swap...${none}"
sudo swapoff -a
echo -e "${green}[DONE]${none}"


echo -ne "${yellow}Waiting for the k8s-master to come up . . . "
retval=1
while [ $retval -ne 0 ]
do
  sudo scp -o StrictHostKeyChecking=no k8s-master:$MAIN_DIR/kubeadm.log $MAIN_DIR/ &> /dev/null
  retval=$?
  echo -ne ". "
  sleep 1s
done
echo

echo -e "${green}kubeadm join command is ready${none}"

echo -ne "${yellow}Waiting for the k8s-master to share the token . . . "
retval=1
while [ $retval -ne 0 ]
do
  sudo scp -o StrictHostKeyChecking=no k8s-master:/$MAIN_DIR/token $MAIN_DIR/ &> /dev/null
  retval=$?
  echo -ne ". "
  sleep 1s
done
echo
echo -e "${green}TOKEN has been gotten${none}"

sudo $(cat $MAIN_DIR/kubeadm.log)

echo -e "${green}------- ALL FINISHED -----"

#echo -e "${yellow}---------------------------------------------------------${none}"
#echo -e "${yellow}Connect to kubernetes master via the kubeadm join command${none}"
#echo -e "${bold}On the master node check the content of kubeadm.log file and "\
#        "issue that command here!${none}"
#echo -e "${yellow}${bold}DO NOT forget to have the token as well from the master node!!!${none}"
#echo -e "${orange}---------------------------------------------------------${none}"
