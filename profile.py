kube_description= \
"""
Levi: Three pure Ubuntu 18.04 connected via LAN. One of them is the OVN k8s-master, while the rest are the two worker nodes.

"""
kube_instruction= \
"""
@master:
- git clone https://github.com/cslev/ovn-k8s
- cd ovn-k8s
- IP addresses needs to be set in master_args.sh (manually?)
- ./master_args.sh #to set the ENV variables for the running shell
- ./ovn_bootstrap.sh #will install all necessary components, including openvswitch 2.10.1 installation from source (check outputs for failures!)
- ./ovn_init_master.sh #will initialize the kubernetes cluster via kubeadm init (also cleans previous attempts' garbage, and sets the hostname, /etc/hosts properly)
- ./ovn_start_master.sh #will practically start ovnkube itself with all its components

@worker node:
- git clone https://github.com/cslev/ovn-k8s
- cd ovn-k8s
- IP addresses needs to be set in minion1_args.sh (manually?)
- ./minion1_args.sh #to set the ENV variables for the running shell
- ./ovn_bootstrap.sh #will install all necessary components, including openvswitch 2.10.1 installation from source (check outputs for failures!)
- ./ovn_init_minion.sh #basic initailization
Then, according to the kubeadm join command the master has generated (stored in kubeadm.log at master) needs to be called from the worker node
The master also created a token (stored in file token at master). We need to copy that file to the worker node's ovn-k8s/ directory
- ./ovn_start_minion.sh #will start ovnkube on the worker node and connects it to the master

"""


# Import the Portal object.
import geni.portal as portal
# Import the ProtoGENI library.
import geni.rspec.pg as pg
# Import the Emulab specific extensions.
import geni.rspec.emulab as emulab
import geni.rspec.igext as IG
import geni.rspec.pg as RSpec

# Create a portal object,
pc = portal.Context()
pc.defineParameter(
    "osNodeType", "Hardware Type",
    portal.ParameterType.NODETYPE, "utah-m400",
    [("", "any available type"), "utah-dl360", "utah-d2950", "utah-m510", "utah-xl170", "utah-m400", "utah-r720"],
    longDescription="http://docs.cloudlab.us/hardware.html A specific hardware type to use for each node.  Cloudlab clusters all have machines of specific types. When you set this field to a value that is a specific hardware type, you will only be able to instantiate this profile on clusters with machines of that type.  If unset, the experiment may have machines of any available type allocated.")
params = pc.bindParameters()

# Create a Request object to start building the RSpec.
request = pc.makeRequestRSpec()


#rspec = RSpec.Request()
tour = IG.Tour()
tour.Description(IG.Tour.TEXT,kube_description)
tour.Instructions(IG.Tour.MARKDOWN,kube_instruction)
request.addTour(tour)

# Node kube-server
kube_m = request.RawPC('m')
kube_m.hardware_type = params.osNodeType
#kube_m.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU16-64-STD'
kube_m.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
kube_m.Site('Site 1')
iface0 = kube_m.addInterface('interface-0')
#set the IP address for the interface
iface0.component_id="eth1"
ip_address_end = 11
ip_address_base="10.10.0."
iface0.addAddress(pg.IPv4Address(ip_address_base + str(ip_address_end),"255.255.255.0"))
bs0 = kube_m.Blockstore('bs0', '/mnt/extra')
bs0.size = '50GB'
bs0.placement = 'NONSYSVOL'

#start main script at master
kube_m.addService(pg.Execute(shell="bash", command="/local/repository/master.sh"))

slave_ifaces = []
for i in [1, 2]:
    kube_s = request.RawPC('s'+str(i))
    #increase IP address' end
    ip_address_end=11+i
    kube_s.hardware_type = params.osNodeType
    #kube_s.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU16-64-STD'
    kube_s.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
    kube_s.Site('Site 1')
    s_iface = kube_s.addInterface('interface-'+str(i))
    s_iface.component_id="eth1"
    s_iface.addAddress(pg.IPv4Address(ip_address_base + str(ip_address_end), "255.255.255.0"))
    slave_ifaces.append(s_iface)

    bs = kube_s.Blockstore('bs'+str(i), '/mnt/extra')
    bs.size = '50GB'
    bs.placement = 'NONSYSVOL'

    kube_s.addService(pg.Execute(shell="bash", command="/local/repository/minion"+str(i)+".sh"))

# Link link-m
link_m = request.Link('link-0')
link_m.Site('undefined')
link_m.addInterface(iface0)
for i in [0, 1]:
    link_m.addInterface(slave_ifaces[i])

# Print the generated rspec
pc.printRequestRSpec(request)
