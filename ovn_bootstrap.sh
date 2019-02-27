#!/bin/bash

source ovn_config.sh

echo -e "${orange}Installing golang...${none}"
if [ -f go1.11.1.linux-amd64.tar.gz ]
then
  echo -e "${green}Compressed archive of go1.11.1 is already downloaded...${none}"
else
  wget https://dl.google.com/go/go1.11.1.linux-amd64.tar.gz
fi
sudo tar -C /usr/local -xzf go1.11.1.linux-amd64.tar.gz
echo -e "${green}[DONE]${none}"

echo -e "${orange}Installing CNI...${none}"
pushd ~/
if [ -f cni-amd64-v0.6.0.tgz ]
then
    echo -e "${green}Compressed archive of cni0.6.0 is already downloaded...${none}"
else
  wget https://github.com/containernetworking/cni/releases/download/v0.6.0/cni-amd64-v0.6.0.tgz
fi

sudo mkdir -p /opt/cni/bin
pushd /opt/cni/bin
sudo tar -xvzf ~/cni-amd64-v0.6.0.tgz
popd
sudo mkdir -p /etc/cni/net.d
# Create a 99loopback.conf to have atleast one CNI config.
echo "{
    "cniVersion": "0.2.0",
    "type": "loopback"
}" > /etc/cni/net.d/99loopback.conf
echo -e "${green}[DONE]${none}"


echo -e "${orange}Adding docker and kubernetes sources to sources.list...${none}"
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates
sudo rm -rf /etc/apt/sources.list.d/kubernetes.list
sudo echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo rm -rf /etc/apt/sources.list.d/docker.list
sudo su -c "echo \"deb https://apt.dockerproject.org/repo ubuntu-xenial main\" > /etc/apt/sources.list.d/docker.list"
sudo apt-get update
echo -e "${green}[DONE]${none}"

echo -e "${orange}Installing docker...${none}"
sudo apt-get install -y linux-image-extra-virtual docker-engine
sudo service docker start
echo -e "${green}[DONE]${none}"

echo -e "${orange}Installing kubernetes...${none}"
sudo apt-get install -y kubelet kubeadm kubectl
sudo service kubelet restart
echo -e "${green}[DONE]${none}"


echo -e "${orange}Compile GO controller if needed...${none}"
echo -ne "${orange}Checking existence of directory 'ovn-kubernetes'..."
if [ -d ./ovn-kubernetes ]
then
  echo -e "${green}[EXISTS...skipping]${none}"
else
  echo -e "${yellow}ovn-kubernetes does not exists, installing...${none}"
  git clone http://github.com/openvswitch/ovn-kubernetes
  cd ovn-kubernetes/go-controller
  make
  sudo make install
  cd ../../
fi
echo -e "${green}[DONE]${none}"

sudo apt-get clean

echo -e "${bold}${yellow}Install openvswitch from source with kernel modules${none}"
echo -e "Hints:"
echo -e "${orange}wget https://www.openvswitch.org/releases/openvswitch-2.10.1.tar.gz${none}"
echo -e "${orange}tar -xzvf openvswitch-2.10.1.tar.gz${none}"
echo -e "${orange}cd openvswitch-2.10.1${none}"
echo -e "${orange}./configure --with-linux=/lib/modules/$(uname -r)/build${none}"
echo -e "${orange}make${none}"
echo -e "${orange}sudo make install${none}"
echo -e "${orange}sudo make modules_install${none}"
echo -e "${green} ---- FINISHED ---- ${none}"



