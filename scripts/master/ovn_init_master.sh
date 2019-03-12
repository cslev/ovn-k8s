#!/bin/bash

#this script initializes the kubernetes and docker background for OVN-KUBERNETES
MAIN_DIR=$1

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
source $MAIN_DIR/scripts/master/master_args.sh


sudo echo

echo -e "${orange}Setting up hostname and hosts aliases...${orange}"
sudo echo "127.0.0.1   ${NODE_NAME}  localhost" | sudo tee /etc/hosts
sudo echo "${CENTRAL_IP}  ${NODE_NAME}" | sudo tee -a /etc/hosts
sudo echo $NODE_NAME | sudo tee /etc/hostname
sudo hostname -F /etc/hostname

$MAIN_DIR/scripts/kill_kubernetes.sh

echo -ne "${orange}Removing previous attempts' garbage..."
sudo rm -rf /etc/kubernetes/manifests/*
sudo rm -rf /var/lib/etcd
sudo rm -rf $HOME/.kube/config
echo -e "${green}[DONE]${none}"

echo -ne "${orange}Stopping KUBELET service...${none}"
sudo service kubelet stop
echo -e "${green}[DONE]${none}"


echo -ne "${orange}Starting DOCKER service...${none}"
sudo service docker start
echo -e "${green}[DONE]${none}"



echo -ne "${orange}Disabling swap...${none}"
sudo swapoff -a
echo -e "${green}[DONE]${none}"

#echo -e "${orange}Pull kubernetes images...${none}"
#sudo kubeadm config images pull
#echo -e "${green}[DONE]${none}"


echo -e "${orange}Initializing kubernetes pod...${none}"
sudo kubeadm init --pod-network-cidr=$POD_IP_RANGE --apiserver-advertise-address=$OVERLAY_IP \
        --service-cidr=$SERVICE_IP_RANGE \
        2>&1 | sudo tee $MAIN_DIR/kubeadm.log
grep "kubeadm join" $MAIN_DIR/kubeadm.log | sudo tee $MAIN_DIR/kubeadm_join
echo -e "${green}[DONE]${none}"

echo -ne "${orange}Copy config to $HOME/.kube/config...${none}"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo -e "${green}[DONE]${none}"

# Wait till kube-apiserver is up
while true; do
    kubectl --kubeconfig=/etc/kubernetes/admin.conf get node $NODE_NAME
    if [ $? -eq 0 ]; then
        break
    fi
    echo -e "${orange}waiting for kube-apiserver to be up${none}"
    sleep 1
done
echo -e "${green}Kube-apiserver is UP!${none}"


echo -e "${orange}Let master run pods too${none}"
kubectl --kubeconfig=/etc/kubernetes/admin.conf taint nodes --all node-role.kubernetes.io/master-
echo -e "${green}[DONE]${none}"
