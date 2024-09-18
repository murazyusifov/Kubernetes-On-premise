# Configure vsphere provider
provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

# Set commonly used variables
locals {
  ssh_user     = "<username>"
  ssh_password = "<password>"
  cpu_count    = <cpu_count>
  memory       = <memory>
  ipv4_gateway = "<gateway_address>"
  dns_server   = "<dns_server>"
  dns_server_2 = "<dns_server>"
  ansible = {
    machine_name = "<machine_name>"
    ipv4_address = "<ipv4_address>"
  }
  kubernetes_master = {
    machine_name = "<machine_name>"
    ipv4_address = "<ipv4_address>"
  }
  kubernetes_worker = {
    machine_name = "<machine_name>"
    ipv4_address = "<ipv4_address>"
  }
}

# Specify datacenter
data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

# Specify datastore
data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Specify host
data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Specify network  
data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Specify folder
data "vsphere_folder" "folder" {
  path = var.vsphere_folder
}

# Specify resource pool 
data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Specify template
data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_vm_template
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Create management virtual machine
resource "vsphere_virtual_machine" "vm" {
  name = local.ansible.machine_name

  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = data.vsphere_folder.folder.path

  num_cpus = local.cpu_count
  memory   = local.memory // in Mb

  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "<disk_name>"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned // enable thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "<host_name>"
        domain    = "<domain_name>"
      }

      network_interface {
        ipv4_address = local.ansible.ipv4_address
        ipv4_netmask = 24
      }

      ipv4_gateway    = local.ipv4_gateway
      dns_server_list = [local.dns_server, local.dns_server_2]
    }
  }

  # Configure user data
  extra_config = {
    "guestinfo.userdata"          = base64encode(file("${path.module}/userdata.yaml"))
    "guestinfo.userdata.encoding" = "base64"
  }
}

# Create kubernetes master node
resource "vsphere_virtual_machine" "kubernetes_master" {
  name = local.kubernetes_master.machine_name

  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = data.vsphere_folder.folder.path

  num_cpus = local.cpu_count
  memory   = local.memory

  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "<disk_name>"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "<host_name>"
        domain    = "<domain_name>"
      }

      network_interface {
        ipv4_address = local.kubernetes_master.ipv4_address
        ipv4_netmask = 24
      }

      ipv4_gateway    = local.ipv4_gateway
      dns_server_list = [local.dns_server, local.dns_server_2]
    }
  }

  # Configure user data
  extra_config = {
    "guestinfo.userdata"          = base64encode(file("${path.module}/userdata.yaml"))
    "guestinfo.userdata.encoding" = "base64"
  }
}

# Create kubernetes worker node
resource "vsphere_virtual_machine" "kubernetes_worker" {
  name = local.kubernetes_worker.machine_name

  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = data.vsphere_folder.folder.path

  num_cpus = local.cpu_count
  memory   = local.memory

  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "<disk_name>"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "<host_name>"
        domain    = "<domain_name>"
      }

      network_interface {
        ipv4_address = local.kubernetes_worker.ipv4_address
        ipv4_netmask = 24
      }

      ipv4_gateway    = local.ipv4_gateway
      dns_server_list = [local.dns_server, local.dns_server_2]
    }
  }

  # Configure user data
  extra_config = {
    "guestinfo.userdata"          = base64encode(file("${path.module}/userdata.yaml"))
    "guestinfo.userdata.encoding" = "base64"
  }
}

# Fetch information about manager machine
data "vsphere_virtual_machine" "vm" {
  depends_on    = [vsphere_virtual_machine.vm]
  name          = vsphere_virtual_machine.vm.name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Fetch information about K8S-master
data "vsphere_virtual_machine" "kubernetes_master" {
  depends_on    = [vsphere_virtual_machine.kubernetes_master]
  name          = vsphere_virtual_machine.kubernetes_master.name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Fetch information about K8S-worker
data "vsphere_virtual_machine" "kubernetes_worker" {
  depends_on    = [vsphere_virtual_machine.kubernetes_worker]
  name          = vsphere_virtual_machine.kubernetes_worker.name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Install Kubernetes 
resource "null_resource" "provision_vm" {
  depends_on = [vsphere_virtual_machine.vm]

  // Configure ssh on K8S-worker node
  provisioner "remote-exec" {
    inline = [
      "echo ${local.ssh_password} | sudo -S apt-get update",

      // Be able to run command with sudo
      "sudo usermod -aG sudo ${local.ssh_user}",

      // Configure SSH
      "sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config",
      "sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config",

      "sudo systemctl daemon-reload",
      "sudo systemctl restart ssh",

      // Set password for root user
      "sudo echo \"root:${local.ssh_password}\" | sudo chpasswd"
    ]

    connection {
      type     = "ssh"
      host     = data.vsphere_virtual_machine.kubernetes_worker.guest_ip_addresses[0]
      user     = local.ssh_user
      password = local.ssh_password
      port     = 22
    }
  }

  // Configure ssh on K8S-master node
  provisioner "remote-exec" {
    inline = [
      "echo ${local.ssh_password} | sudo -S apt-get update",

      // Be able to run command with sudo
      "sudo usermod -aG sudo ${local.ssh_user}",

      // Configure SSH
      "sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config",
      "sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config",

      "sudo systemctl daemon-reload",
      "sudo systemctl restart ssh",

      // Set password for root user
      "echo \"root:${local.ssh_password}\" | sudo chpasswd"
    ]

    connection {
      type     = "ssh"
      host     = data.vsphere_virtual_machine.kubernetes_master.guest_ip_addresses[0]
      user     = local.ssh_user
      password = local.ssh_password
      port     = 22
    }
  }

  // Install python script into machine
  provisioner "file" {
    source      = "script.py"
    destination = "/home/terraform/script.py"

    connection {
      type     = "ssh"
      host     = data.vsphere_virtual_machine.vm.guest_ip_addresses[0]
      user     = local.ssh_user
      password = local.ssh_password
      port     = 22
    }
  }

  // Kubernetes Installation
  provisioner "remote-exec" {
    inline = [
      "echo ${local.ssh_password} | sudo -S apt-get update",

      // Be able to run sudo commands
      "sudo usermod -aG sudo ${local.ssh_user}",

      // Install python3
      "sudo DEBIAN_FRONTEND=noninteractive apt install git python3 python3-pip -y",

      // Change to home directory
      "cd ~",

      // Install Kubespray
      "git clone https://github.com/kubernetes-sigs/kubespray.git",

      // Install dependencies
      "cd kubespray/",
      "sudo pip install -r requirements.txt",

      // Add SSH keys into K8S machines
      "sudo rm /root/.ssh/id_rsa", // If there are already generated files, delete them
      "sudo rm /root/.ssh/id_rsa.pub",

      // Generate private and public key pairs
      "sudo ssh-keygen -t rsa -b 4096 -N \"\" -f /root/.ssh/id_rsa",

      // Install sshpass
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install sshpass",

      // Copy SSH keys into K8S machines
      "sudo sshpass -p ${local.ssh_password} ssh-copy-id -o StrictHostKeyChecking=no root@${data.vsphere_virtual_machine.kubernetes_master.guest_ip_addresses[0]}",
      "sudo sshpass -p ${local.ssh_password} ssh-copy-id -o StrictHostKeyChecking=no root@${data.vsphere_virtual_machine.kubernetes_worker.guest_ip_addresses[0]}",

      // Configure kubespray
      "cd ~/kubespray/",

      // Create cluster folder
      "cp -rfp inventory/sample inventory/mycluster",

      // Install python3-pip
      "sudo apt-get install -y python3-pip",

      // Install ruamel.yaml module
      "sudo pip3 install ruamel.yaml",
      
      // Declare machines' IP addresses
      "bash -c 'CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py \"${data.vsphere_virtual_machine.kubernetes_master.guest_ip_addresses[0]}\" \"${data.vsphere_virtual_machine.kubernetes_worker.guest_ip_addresses[0]}\"'",
      
      // Install pyyaml module
      "sudo pip3 install pyyaml",

      // Install dos2unix 
      "sudo DEBIAN_FRONTEND=noninteractive apt install dos2unix",
      
      // Run python script
      "chmod +x /home/terraform/script.py",
      "dos2unix /home/terraform/script.py",
      "/home/terraform/script.py",

      // Configure Kubernetes addons
      "sed -i 's/^ingress_nginx_enabled: false/ingress_nginx_enabled: true/' /home/terraform/kubespray/inventory/mycluster/group_vars/k8s_cluster/addons.yml",
      "sudo sed -i 's/^# ingress_nginx_host_network: false/ingress_nginx_host_network: true/' /home/terraform/kubespray/inventory/mycluster/group_vars/k8s_cluster/addons.yml",

      // Enable IPv4 forwarding and disable swap on all the nodes
      "sudo ansible all -i /home/terraform/kubespray/inventory/mycluster/updated_hosts.yaml -m shell -a \"echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf\"",
      "sudo ansible all -i /home/terraform/kubespray/inventory/mycluster/updated_hosts.yaml -m shell -a \"sudo sed -i '/ swap / s/^\\(.*\\)$/#\\1/g' /etc/fstab && sudo swapoff -a\"",

      // Run playbook
      "sudo ansible-playbook -i /home/terraform/kubespray/inventory/mycluster/updated_hosts.yaml --become --become-user=root /home/terraform/kubespray/cluster.yml"
    ]

    connection {
      type     = "ssh"
      host     = data.vsphere_virtual_machine.vm.guest_ip_addresses[0]
      user     = local.ssh_user
      password = local.ssh_password
      port     = 22
    }
  }
}