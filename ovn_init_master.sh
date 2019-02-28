#!/bin/bash

#this script initializes the kubernetes and docker background for OVN-KUBERNETES


source ovn_config_master.sh

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

echo -e "${orange}Pull kubernetes images...${none}"
sudo kubeadm config images pull
echo -e "${green}[DONE]${none}"


echo -e "${orange}Initializing kubernetes pod...${none}"
sudo kubeadm init --pod-network-cidr=$POD_IP_RANGE --apiserver-advertise-address=$OVERLAY_IP \
        --service-cidr=$SERVICE_IP_RANGE \
        2>&1 | tee kubeadm.log
grep "kubeadm join" kubeadm.log | sudo tee kubeadm.log
echo -e "${green}[DONE]${none}"

echo -ne "${orange}Copy config to $HOME/.kube/config...${none}"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo -e "${green}[DONE]${none}"

# Wait till kube-apiserver is up
while true; do
    kubectl get node $NODE_NAME
    if [ $? -eq 0 ]; then
        break
    fi
    echo -e "${orange}waiting for kube-apiserver to be up${none}"
    sleep 1
done
echo -e "${green}Kube-apiserver is UP!${none}"


echo -ne "${orange}Let master run pods too${none}"
kubectl taint nodes --all node-role.kubernetes.io/master-
echo -e "${green}[DONE]${none}"








