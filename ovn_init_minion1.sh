#!/bin/bash

#this script initializes the kubernetes and docker background for OVN-KUBERNETES

source minion1_args.sh
source ovn_config.sh

sudo echo

echo -e "${orange}Setting up hostname and hosts aliases...${orange}"
sudo echo "127.0.0.1   ${NODE_NAME}  localhost" | sudo tee /etc/hosts
sudo echo "${CENTRAL_IP}  k8s-master" | sudo tee -a /etc/hosts
sudo echo "${OVERLAY_IP}  ${NODE_NAME}"| sudo tee -a /etc/hosts
sudo echo $NODE_NAME | sudo tee /etc/hostname
sudo hostname -F /etc/hostname


./kill_kubernetes.sh

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


echo -ne "${yellow}Waiting for the k8s-master to come up . . ."
retval=1
while [ $retval -ne 0 ]
do
  sudo scp -o StrictHostKeyChecking=no k8s-master:/users/cslev/ovn-k8s/kubeadm.log ./ &> /dev/null
  retval=$?
  echo -ne ". "
  sleep 1s
done
echo

echo -e "${green}kubeadm join command is ready${none}"

echo -ne "${yellow}Waiting for the k8s-master to share the token . . ."
retval=1
while [ $retval -ne 0 ]
do
  sudo scp -o StrictHostKeyChecking=no k8s-master:/users/cslev/ovn-k8s/token ./ &> /dev/null
  retval=$?
  echo -ne ". "
  sleep 1s
done
echo

echo -e "${green}------- ALL FINISHED -----"

#echo -e "${yellow}---------------------------------------------------------${none}"
#echo -e "${yellow}Connect to kubernetes master via the kubeadm join command${none}"
#echo -e "${bold}On the master node check the content of kubeadm.log file and "\
#        "issue that command here!${none}"
#echo -e "${yellow}${bold}DO NOT forget to have the token as well from the master node!!!${none}"
#echo -e "${orange}---------------------------------------------------------${none}"








