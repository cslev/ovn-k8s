#!/bin/bash

source ovn_config.sh

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

echo -ne "${orange}Create OVN databases for northbound and southbound${none}"
sudo ovsdb-tool create $OVN_DB_FILE_DIR/ovnnb_db.db $OVN_DB_SCHEMA_DIR/ovn-nb.ovsschema
sudo ovsdb-tool create $OVN_DB_FILE_DIR/ovnsb_db.db $OVN_DB_SCHEMA_DIR/ovn-sb.ovsschema
echo -e "${green}[DONE]${none}"

echo -e "${orange}Create DB_SOCK for the databases"
echo -ne "${orange} -> OVS..."
#sudo ovsdb-server --detach --monitor -vconsole:off \
#                  --log-file=$OVN_LOG_DIR/ovsdb-server-ovsdb.log \
#                  --remote=punix:$OVN_SOCKET_DIR/db.sock \
#                  --pidfile=$OVN_PID_DIR/ovs_db.pid \
#                  --remote=db:Open_vSwitch,Open_vSwitch,manager_options
sudo ovsdb-server --remote=punix:$OVN_SOCKET_DIR/db.sock \
                  --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
                  --pidfile --detach
echo -e "${green}[DONE]${none}"

echo -ne "${orange} -> OVN northbound..."
sudo ovsdb-server --detach --monitor -vconsole:off \
             --log-file=$OVN_LOG_DIR/ovsdb-server-nb.log \
             --remote=punix:$OVN_SOCKET_DIR/ovnnb_db.sock \
             --pidfile=$OVN_PID_DIR/ovnnb_db.pid \
             --remote=db:OVN_Northbound,NB_Global,connections \
             --remote=ptcp:6641:$OVERLAY_IP \
             --unixctl=ovnnb_db.ctl \
             --private-key=db:OVN_Northbound,SSL,private_key \
             --certificate=db:OVN_Northbound,SSL,certificate \
             --ca-cert=db:OVN_Northbound,SSL,ca_cert \
             $OVN_DB_FILE_DIR/ovnnb_db.db
echo -e "${green}[DONE]${none}"

echo -ne "${orange} -> OVN southbound..."
sudo ovsdb-server --detach --monitor -vconsole:off \
             --log-file=$OVN_LOG_DIR/ovsdb-server-sb.log \
             --remote=punix:$OVN_SOCKET_DIR/ovnsb_db.sock \
             --pidfile=$OVN_PID_DIR/ovnsb_db.pid \
             --remote=db:OVN_Southbound,SB_Global,connections \
             --remote=ptcp:6642:$OVERLAY_IP \
             --unixctl=ovnsb_db.ctl \
             --private-key=db:OVN_Southbound,SSL,private_key \
             --certificate=db:OVN_Southbound,SSL,certificate \
             --ca-cert=db:OVN_Southbound,SSL,ca_cert \
             $OVN_DB_FILE_DIR/ovnsb_db.db
echo -e "${green}[DONE]${none}"

echo
echo -e "${orange}Starting pure OVS...${none}"
sudo ovs-vsctl --no-wait \
               init
sudo ovs-vswitchd unix:$OVN_SOCKET_DIR/db.sock \
                  --pidfile=$OVN_PID_DIR/ovsvswitchd.pid \
                  --detach
echo -e "${green}[DONE]${none}"


echo
echo -e "${orange}Starting ovn northd...${none}"
sudo $OVN_CTL start_northd
echo -e "${green}[DONE]${none}"

echo -e "${orange}Starting ovn controller...${none}"
sudo $OVN_CTL start_controller
echo -e "${green}[DONE]${none}"


echo -e "${orange}Create OVNKUBE networking${none}"
sudo kubectl create -f  ovnkube-rbac.yaml
echo -e "${green}[DONE]${none}"

# getting secret for the freshly created ovnkube
SECRET=`kubectl get secret | grep ovnkube | awk '{print $1}'`
TOKEN=`kubectl get secret/$SECRET -o yaml |grep "token:" | cut -f2  -d ":" | sed 's/^  *//' | base64 -d`
echo $TOKEN > token

echo -e "${orange}Starting OVNKUBE...${none}"
sudo ovnkube -net-controller -loglevel=8 \
             -k8s-apiserver="https://$OVERLAY_IP:6443" \
             -k8s-cacert=/etc/kubernetes/pki/ca.crt \
             -k8s-token="$TOKEN" \
             -logfile="${OVN_LOG_DIR}/ovnkube.log" \
             -init-master=$NODE_NAME \
             -init-node=$NODE_NAME \
             -service-cluster-ip-range=$SERVICE_IP_RANGE \
             -nodeport \
             -nb-address="tcp://${OVERLAY_IP}:6641" \
             -sb-address="tcp://${OVERLAY_IP}:6642" \
             -init-gateways \
             -gateway-localnet

echo -e "${green}[DONE]${none}"


echo -e "${green} --- FINISHED --- ${none}"
echo
