# On-Premise Kubernetes Cluster Setup 

This repository contains the setup and configuration files for deploying a Kubernetes cluster on an on-premise environment (vSphere) using Terraform and Kubespray.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Key Features](#key-features)
- [Cluster Configuration](#cluster-configuration)
- [Accessing the Cluster](#accessing-the-cluster)
- [Cleanup](#cleanup)

## Overview

The goal of this project is to automate the provisioning and deployment of a Kubernetes cluster using the following tools:
- **Terraform**: For Infrastructure as Code (IaC) to provision virtual machines (VMs) in vSphere.
- **Kubespray**: For deploying Kubernetes on the provisioned VMs using Ansible playbooks.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (the latest version is recommended)
- Access to a vSphere environment with appropriate permissions
- Git installed for cloning this repository

## Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/k8s-vsphere-terraform-kubespray.git
   cd k8s-vsphere-terraform-kubespray```

2. **Run the Script**

    ```bash 
    terraform init
    terraform apply -auto-approve
    ```

## Key Features
- Automated VM provisioning on vSphere using Terraform.
- Configurable infrastructure, including CPU, memory, and storage for each node.
- Multi-node Kubernetes cluster setup (1 master and multiple workers).
- Full Kubernetes installation and configuration using Kubespray.
- Highly available and scalable infrastructure.

## Cluster Configuration

In this project, three virtual machines (VMs) were provisioned, each serving a distinct role in the Kubernetes cluster:

1. **Manager**:
   - This node is responsible for installing and managing the Kubernetes components on all the machines (K8S-master and K8S-worker nodes) via **Kubespray**.
   - It uses **Ansible** to automate the configuration and deployment of Kubernetes.
   - It does not participate in the Kubernetes cluster directly but plays a key role in orchestrating the setup.

2. **K8S-master**:
   - The master node is the brain of the Kubernetes cluster. It runs the **Kubernetes Control Plane** components:
     - **API Server**: The front-end that interacts with `kubectl` and other API consumers.
     - **Scheduler**: Decides which nodes run the pods.
     - **Controller Manager**: Monitors the state of the cluster and ensures that the desired state matches the current state.
     - **etcd**: A distributed key-value store that holds the cluster's configuration data and the state of all the objects.
   - The master node controls the entire cluster, managing workloads and communication between worker nodes.

3. **K8S-worker**:
   - Worker nodes are the machines where the actual application workloads (pods) run.
   - Each worker node runs two key components:
     - **Kubelet**: Communicates with the master node to receive instructions and execute them (e.g., start/stop containers).
     - **Kube-proxy**: Manages networking for the pods, providing load balancing and network connectivity.
   - This node is scalable, meaning more worker nodes can be added to increase the cluster's capacity to run workloads.

Note: if you decide on other cluster configuration, there are necessary commands in python script! 

## Accessing the Cluster

To interact with the Kubernetes cluster from within the **k8s-master** or **k8s-worker** machines, you must switch to the `root` user to use the `kubectl` command:

1. **SSH into the master node** (or a worker node if needed):

   ```bash
   ssh <user>@<master-node-ip>
   ```

2. **Switch to root user**

    ```bash
    sudo su
    ```

3. **Verify the cluster is running using kubectl commands**

    ```bash
    kubectl get nodes
    kubectl get pods -A
    ```

## Cleanup

When you're finished with the Kubernetes cluster and no longer need the resources, you can safely remove all provisioned virtual machines and Kubernetes configurations.

  **Run one terraform command to destroy all provisioned VMs**

  ```bash
  terraform destroy -auto-approve
  ```
