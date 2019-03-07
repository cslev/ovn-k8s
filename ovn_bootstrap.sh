#!/bin/bash
source ovn_config.sh
source master_args.sh


check_retval ()
{
  retval=$1
  if [ $retval -ne 0 ]
  then
    echo -e "${bold}${red}Something went wrong during the installation process..."
    echo -e "EXITING${none}"
    exit -1
  else
    echo -e "${green}[DONE]${none}"
  fi

}

sudo echo


echo -e "${orange}Install openvswitch requirements...${none}"
sudo apt-get update

sudo apt-get install -y gcc g++ libclang-6.0-dev libclang-common-6.0-dev libssl-dev wget tar bzip2 \
                        libssl1.0.0 \
                        libssl1.1 \
                        libcap-ng-dev \
                        libcapnp-dev \
                        libcap-ng-utils \
                        libcap-ng0 \
                        python python-cap-ng python-six python2.7 python-pyftpdlib python-tftpy \
                        autoconf automake autotools-dev \
                        libtool \
                        netcat \
                        curl
retval=$?
check_retval $retval


echo -e "${orange}Installing golang...${none}"
if [ -f go1.11.1.linux-amd64.tar.gz ]
then
  echo -e "${green}Compressed archive of go1.11.1 is already downloaded...${none}"
else
  wget https://dl.google.com/go/go1.11.1.linux-amd64.tar.gz
  retval=$?
  check_retval $retval
fi
sudo tar -C $GOPATH -xzf go1.11.1.linux-amd64.tar.gz
retval=$?
check_retval $retval

echo -e "${orange}Installing CNI...${none}"
CNI_PATH=$(pwd)
pushd $CNI_PATH
if [ -f cni-amd64-v0.6.0.tgz ]
then
    echo -e "${green}Compressed archive of cni0.6.0 is already downloaded...${none}"
else
    wget https://github.com/containernetworking/cni/releases/download/v0.6.0/cni-amd64-v0.6.0.tgz
    retval=$?
    check_retval $retval
fi

sudo mkdir -p /opt/cni/bin
pushd /opt/cni/bin
sudo tar -xvzf $CNI_PATH/cni-amd64-v0.6.0.tgz
popd
sudo mkdir -p /etc/cni/net.d
# Create a 99loopback.conf to have atleast one CNI config.
sudo echo "{
    "cniVersion": "0.2.0",
    "type": "loopback"
}" | sudo tee /etc/cni/net.d/99loopback.conf
echo -e "${green}[DONE]${none}"

echo -ne "${orange}Create initramfs for the running kernel...${none}"
sudo update-initramfs -c -k $(uname -r)
retval=$?
check_retval $retval

echo -e "${orange}Adding docker and kubernetes sources to sources.list...${none}"
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates uuid
sudo rm -rf /etc/apt/sources.list.d/kubernetes.list
sudo echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo rm -rf /etc/apt/sources.list.d/docker.list
sudo echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" |sudo tee /etc/apt/sources.list.d/docker.list
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

echo -e "${orange}Pull kubernetes images...${none}"
sudo kubeadm config images pull
echo -e "${green}[DONE]${none}"


echo -e "${orange}Compile GO controller if needed...${none}"
echo -ne "${orange}Checking existence of directory 'ovn-kubernetes'..."
if [ -d ./ovn-kubernetes ]
then
  echo -e "${green}[EXISTS...skipping]${none}"
else
  echo -e "${orange}ovn-kubernetes does not exists, installing...${none}"
  git clone http://github.com/openvswitch/ovn-kubernetes
  cd ovn-kubernetes/go-controller
  echo -e "${orange}Compiling...${none}"
  make
  retval=$?
  check_retval $retval

  echo -e "${orange}Installing...${none}"
  sudo make install
  retval=$?
  check_retval $retval

  cd ../../
fi



sudo apt-get clean

echo -e "${orange}Installing openvswitch from source with kernel modules...${none}"
echo -e "${orange}Getting openvswitch 2.10.1...${none}"

if [ -f openvswitch-2.10.1.tar.gz ]
then
  echo -e "${orange}openvswitch-2.10.1.tar.gz already downloaded...${none}"
else
  sudo wget https://www.openvswitch.org/releases/openvswitch-2.10.1.tar.gz
  retval=$?
  check_retval $retval
fi

echo -e "${orange}Extracting and configuring Open vSwitch...${none}"
sudo tar -xzf openvswitch-2.10.1.tar.gz
retval=$?
check_retval $retval
pushd $(pwd)
pushd openvswitch-2.10.1
./configure --with-linux=/lib/modules/$(uname -r)/build

echo -e "${orange}Compiling Open vSwitch...${none}"
make -j
retval=$?
check_retval $retval
echo -e "${green}[DONE]${none}"

echo -e "${orange}Installing binaries...${none}"
sudo make install
retval=$?
check_retval $retval

echo -e "${orange}Create self-signing keys for installing kernel modules${none}"
sudo rm -rf key.pem
sudo rm -rf certificate.pem
sudo openssl req -new -x509 -sha512 -newkey rsa:4096 -nodes -keyout key.pem -days 36500 -out certificate.pem \
     -subj "/C=HU/ST=PEST/L=Budapest/O=BME/OU=TMIT/CN=HSNLab"
sudo cp key.pem /usr/src/linux-headers-$(uname -r)/certs/signing_key.pem
sudo cp certificate.pem /usr/src/linux-headers-$(uname -r)/certs/signing_key.x509
echo -e "${green}[DONE]${none}"


echo -e "${orange}Installing kernel modules...${none}"
sudo make modules_install
retval=$?
check_retval $retval

echo -en "${orange}Inserting module...${none}"
sudo modprobe openvswitch
retval=$?
check_retval $retval

echo -e "${green} ---- FINISHED ---- ${none}"
echo -e "${bold}${yellow}\n" \
        "----====== ATTENTION ======----"
echo -e "DO NOT forget to set OVERLAY_IP \n" \
        "variable to your local IP in \n" \
	"${underline}master_args.sh${bold} and" \
        "${underline}minion_args.sh${bold}, respectively!\n" \
        "----=======================----${none}"


