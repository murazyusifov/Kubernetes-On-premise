#!/usr/bin/env python3

import yaml

# Load the existing YAML file
with open("/home/terraform/kubespray/inventory/mycluster/hosts.yaml", "r") as file:
    data = yaml.safe_load(file)

'''
By default there are as many host names as declared IP addresses, to customize naming use the belowmentioned commands
'''

# Change default hostnames
data["all"]["hosts"]["master"] = data["all"]["hosts"].pop("node1")
data["all"]["hosts"]["worker"] = data["all"]["hosts"].pop("node2")

# Delete default hostnames under kube_control_plane block under children section
data["all"]["children"]["kube_control_plane"]["hosts"]["master"] = {}
del data["all"]["children"]["kube_control_plane"]["hosts"]["node1"]
del data["all"]["children"]["kube_control_plane"]["hosts"]["node2"]

# Update the 'children' section to reflect the new hostnames
data["all"]["children"]["kube_control_plane"] = {"hosts": {"master": None}}
data["all"]["children"]["kube_node"] = {"hosts": {"worker": None}}
data["all"]["children"]["etcd"] = {"hosts": {"master": None}}
data["all"]["children"]["k8s_cluster"] = {
    "children": {
        "kube_control_plane": None,
        "kube_node": None
    }
}
data["all"]["children"]["calico_rr"] = {"hosts": {}}

# Save the updated YAML file
with open("/home/terraform/kubespray/inventory/mycluster/updated_hosts.yaml", "w") as file:
    yaml.dump(data, file, default_flow_style=False)
