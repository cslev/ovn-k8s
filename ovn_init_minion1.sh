#!/bin/bash

#this script initializes the kubernetes and docker background for OVN-KUBERNETES

source minion1_args.sh
source ovn_config.sh

sudo echo

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


echo -e "${orange}---------------------------------------------------------${none}"
echo -e "${orange}Connect to kubernetes master via the kubeadm join command${none}"
echo -e "${bold}On the master node check the content of kubeadm.log file and "\
        "issue that command here!${none}"
echo -e "${orange}---------------------------------------------------------${none}"








