#!/bin/bash

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
  echo -e "${red}MINION_ID as second argument has not been defined! Use 1,2,...,N for setting it properly${none}"
  exit -1
fi
source $MAIN_DIR/scripts/minion/minion${MINION_ID}_args.sh

echo -ne "${orange}Create necessary directories if not exist...${none}"
sudo mkdir -p $OVN_PID_DIR
sudo mkdir -p $OVN_DB_FILE_DIR
sudo mkdir -p $OVN_LOG_DIR
sudo mkdir -p $OVN_SOCKET_DIR
sudo mkdir -p /var/run/openvswitch
echo -e "${green}[DONE]${none}"

echo -ne "${orange}Create OVS database...${none}"
sudo ovsdb-tool create $OVN_DB_FILE_DIR/conf.db  $OVN_DB_SCHEMA_DIR/vswitch.ovsschema
echo -e "${green}[DONE]${none}"

echo -e "${orange}Create DB_SOCK for the databases"
echo -ne "${orange} -> OVS..."
sudo ovsdb-server --remote=punix:$OVN_SOCKET_DIR/db.sock \
                  --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
                  --pidfile --detach
echo -e "${green}[DONE]${none}"

echo
echo -e "${orange}Starting pure OVS...${none}"
sudo ovs-vsctl --no-wait \
               init
sudo ovs-vswitchd unix:$OVN_SOCKET_DIR/db.sock \
                  --pidfile=$OVN_PID_DIR/ovsvswitchd.pid \
                  --detach
echo -e "${green}[DONE]${none}"

echo -e "${orange}Getting SYSTEM_ID from /sys/class/dmi/id/product_id...${none}"
SYSTEM_ID=$(sudo cat /sys/class/dmi/id/product_uuid)
echo -e "${green}[DONE]${none}"


echo -e "${orange}Setting SYSTEM_ID in OVS DB...${none}"
sudo ovs-vsctl set Open_vSwitch . external_ids:system-id="${SYSTEM_ID}"
echo -e "${green}[DONE]${none}"

TOKEN=$(cat $MAIN_DIR/token)
if [ -z "$TOKEN" ]
then
  echo -e "${red}variable TOKEN does not exists! Get token of ovnkube from server and save as a text file called 'token' here!${none}"
  echo -e "Example: kubectl get secret|grep ovnkube"
  exit -1
else
#  echo -e "${orange}Starting ovn-controller...${none}"
#  sudo ovn-controller

  echo -e "${orange}Starting OVNKUBE...${none}"
  sudo $OVNKUBE_PATH -loglevel=8 \
                     -logfile="${OVN_LOG_DIR}/ovnkube.log" \
                     -k8s-apiserver="https://$CENTRAL_IP:6443" \
                     -k8s-cacert=/etc/kubernetes/pki/ca.crt \
                     -init-node=$NODE_NAME \
                     -nodeport \
                     -nb-address="tcp://${CENTRAL_IP}:6641" \
                     -sb-address="tcp://${CENTRAL_IP}:6642" \
                     -k8s-token="$TOKEN" \
                     -init-gateways \
                     -gateway-interface=$IFNAME \
                     -gateway-nexthop=$GW_IP \
                     -service-cluster-ip-range=$SERVICE_IP_RANGE \
                     -cluster-subnet=$POD_IP_RANGE
#               -k8s-cacert=/etc/kubernetes/pki/ca.crt \
#               -gateway-localnet 2>&1 &
#               -net-controller \

  echo -e "${orange}OVNKUBE (might) have not started properly as ovn-controller does not know where to connect to"
  echo -e "${orange}Restart ovn-controller...${none}"
  sudo pkill ovn-controller
  sudo ovn-controller 2>&1 &
  echo -e "${orange}Restarting OVNKUBE...${none}"
  sudo ovnkube -loglevel=8 \
               -logfile="${OVN_LOG_DIR}/ovnkube.log" \
               -k8s-apiserver="https://$CENTRAL_IP:6443" \
               -k8s-cacert=/etc/kubernetes/pki/ca.crt \
               -init-node=$NODE_NAME \
               -nodeport \
               -nb-address="tcp://${CENTRAL_IP}:6641" \
               -sb-address="tcp://${CENTRAL_IP}:6642" \
               -k8s-token="$TOKEN" \
               -init-gateways \
               -gateway-interface=$IFNAME \
               -gateway-nexthop=$GW_IP \
               -service-cluster-ip-range=$SERVICE_IP_RANGE \
               -cluster-subnet=$POD_IP_RANGE 2>&1 &

  sleep 3
  echo -e "${green}[DONE]${none}"
  echo -e "${green} --- FINISHED --- ${none}"

  echo -e "${green}Freshesh output log of ovnkube:${none}"

  sudo tail -n 20 $OVN_LOG_DIR/ovnkube.log

  echo -e "${green}Check the status of k8s-minion node at k8s-master via kubectl get nodes!${none}"

fi
