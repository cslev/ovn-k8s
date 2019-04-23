#!/bin/bash
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

cd $MAIN_DIR
./scripts/ovn_stop.sh

pushd ovn-kubernetes/go-controller/
sudo make clean
popd
sudo rm -rf ovn-kubernetes


echo -e "${orange}Stopping kubelet service...${none}"
sudo service kubelet stop
echo -e "${green}[DONE]${none}"

echo -e "${orange}Stopping docker containers...${none}"
for i in $(sudo docker ps -q)
do
  sudo docker stop $i
done
echo -e "${green}[DONE]${none}"


echo -e "${orange}Removing docker containers...${none}"
for i in $(sudo docker ps -a -q)
do
  sudo docker rm $i
done
echo -e "${green}[DONE]${none}"


echo -e "${orange}Removing docker images...${none}"
for i in $(sudo docker images -q)
do
  sudo docker rmi $i
done
echo -e "${green}[DONE]${none}"

echo -e "${orange}Stopping docker and kubelet service...${none}"
sudo service docker stop
sudo service kubelet stop
echo -e "${green}[DONE]${none}"


echo -e "${orange}Removing docker and kubernetes packages...${none}"
sudo apt-get remove --purge docker-engine kubelet kubeadm kubectl -y
sudo apt-get autoremove -y
sudo apt-get clean
echo -e "${green}[DONE]${none}"

echo -ne "${orange}Removing all related files and directories"
sudo rm -rf /var/lib/kubelet
sleep 0.5
echo -ne ". "
sudo rm -rf /etc/kubernetes
sleep 0.5
echo -ne ". "
sudo rm -rf /usr/libexec/kubernetes
sleep 0.5
echo -ne ". "
sudo rm -rf /etc/default/kubelet
sleep 0.5
echo -ne ". "
sudo rm -rf /var/lib/docker
sleep 0.5
echo -ne ". "
sudo rm -rf /etc/docker
sleep 0.5
echo -ne ". "
sudo rm -rf /var/lib/dockershim
sleep 0.5
echo -ne ". "
sudo rm -rf /var/lib/etcd
sleep 0.5
echo -ne ". "
sudo rm -rf /var/log/pods
sleep 0.5
echo -ne ". "
sudo rm -rf /var/log/containers
sleep 0.5
sudo rm -rf /opt/cni/bin/
sleep 0.5
echo -e "${green}[DONE]${none}"
