# ovn-k8s
Scripts to install ovn-kubernetes on bare metal machine(s)

## Main purpose
The repository is created for Cloudlab, which means that the `profile.py` is a description for the cloudlab environment setting up 3 (virtual) machines and installs everything from scratch!

## DIY mode (step-by-step)
In order to make it for your own environment, you need to have 3 (virtual) machines connected via LAN (e.g., having interfaces with IP addresses 10.10.0.11 (master), 10.10.0.12 (worker node 1), and 10.10.0.13 (worker node 2), respectively.
Your machines should be accessible all the time via another interface/IP address in order to avoid keeping ourselves out from the machines after a certain point.

Do the following steps on the machines
### @master node:
The following commands shoud be executed:
```
$ git clone https://github.com/cslev/ovn-k8s
$ cd ovn-k8s/scripts
```

Install all necessary components, including openvswitch 2.10.1 installation from source (check outputs for failures!)
```
$ sudo ./ovn_bootstrap.sh /ovn-k8s
```

Initialize the kubernetes cluster via kubeadm init (also cleans previous attempts' garbage, and sets the hostname, /etc/hosts properly)
```
$ sudo ./master/ovn_init_master.sh /ovn-k8s
```

Practically start ovnkube itself with all its components
```
$ sudo ./master/ovn_start_master.sh /ovn-k8s
```
The above command will also produce a kubeadm join command for the workers, as well as a token for connecting.
In order to make them available for the minions, the IP addresses mentioned above should be set properly, and SSH keys NEEDS to be exchanged between the master and the worker nodes, since the worker nodes will download (via `scp`) the required files from the master!
If the connection is not set properly, the worker nodes could not be initialized.

### @worker node(s):
The following commands should be executed:
```
$ cd /
$ sudo git clone https://github.com/cslev/ovn-k8s
$ sudo cd ovn-k8s/scripts
```

Install all necessary components, including openvswitch 2.10.1 installation from source (check outputs for failures!)
```
$ sudo ./ovn_bootstrap.sh /ovn-k8s
```

Basic initailization ($MINION_ID = [1, 2] depending on which worker node you are installing (first one with IP 10.10.0.12 or the second one with IP 10.10.0.13))
```
$ sudo ./minion/ovn_init_minion.sh $MINION_ID /ovn-k8s
```

Then, according to the kubeadm join command the master has generated (stored in kubeadm.log at master) will be called from the worker node.
The master also created a token (stored in file token at master).

Start ovnkube on the worker node and connects it to the master
```
sudo ./minion/ovn_start_minion.sh $MINION_ID /ovn-k8s
```

## DIY mode (lazy)
### @master node:
$ cd /
$ sudo git clone https://github.com/cslev/ovn-k8s
$ sudo cd ovn-k8s
$ sudo ./master.sh /ovn-k8s
```

### @worker node(s):
```
$ cd /
$ sudo git clone https://github.com/cslev/ovn-k8s
$ sudo cd ovn-k8s
$ sudo ./minion.sh $MINION_ID /ovn-k8s

```
