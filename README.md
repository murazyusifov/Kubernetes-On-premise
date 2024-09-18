# On-Premise Kubernetes Cluster Setup with Terraform and Kubespray

This repository contains the setup and configuration files for deploying a Kubernetes cluster on an on-premise environment (vSphere) using Terraform and Kubespray.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Cluster Configuration](#cluster-configuration)
- [Deployment](#deployment)
- [Accessing the Cluster](#accessing-the-cluster)
- [Cleanup](#cleanup)
- [License](#license)

## Overview

This project demonstrates how to provision a Kubernetes cluster on a vSphere environment using Terraform for infrastructure management and Kubespray for Kubernetes deployment. 

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (version X.X.X)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (version X.X.X)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (version X.X.X)
- Access to a vSphere environment with appropriate permissions
- Git installed for cloning this repository

## Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/k8s-vsphere-terraform-kubespray.git
   cd k8s-vsphere-terraform-kubespray
