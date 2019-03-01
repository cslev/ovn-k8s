#!/bin/bash

#this script initializes the kubernetes and docker background for OVN-KUBERNETES

source minion1_args.sh
source ovn_config.sh

sudo echo

echo -ne "${orange}Cleaning previous attempts' gargabe...${none}"
sudo pkill etcd
sudo pkill kube-apiserver
sudo pkill kube-controller-manager
sudo pkill kube-scheduler
sudo rm -rf /var/lib/etcd
sudo rm -rf /etc/kubernetes/manifests/*
sudo rm -rf $HOME/.kube
sudo rm -rf /var/log/openvswitch/ovnkube.log
sudo rm -rf /etc/kubernetes/*


sudo service kubelet stop
sudo service docker stop
echo -e "${green}[DONE]${none}"



echo -ne "${orange}Starting DOCKER service...${none}"
sudo service docker start
echo -e "${green}[DONE]${none}"


#echo -ne "${orange}Starting KUBELET service...${none}"
sudo service kubelet restart
#echo -e "${green}[DONE]${none}"


echo -ne "${orange}Disabling swap...${none}"
sudo swapoff -a
echo -e "${green}[DONE]${none}"


echo -e "${orange}---------------------------------------------------------${none}"
echo -e "${orange}Connect to kubernetes master via the kubeadm join command${none}"
echo -e "${bold}On the master node check the content of kubeadm.log file and "\
echo -e "issue that command here!${none}"
echo -e "${orange}---------------------------------------------------------${none}"








