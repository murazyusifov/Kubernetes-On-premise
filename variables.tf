variable "vsphere_server" {
  description = "vsphere URL"
  default     = "<vsphere_url>"
}

variable "vsphere_user" {
  description = "vsphere user"
  default     = "<vsphere_user>"
}

variable "vsphere_password" {
  description = "vsphere password"
  default     = "<vsphere_password>"
}

variable "vsphere_datacenter" {
  description = "datacenter name"
  default     = "<datacenter_name>"
}

variable "vsphere_datastore" {
  description = "datastore name"
  default     = "<datastore_name>"
}

variable "vsphere_host" {
  description = "host name"
  default     = "<host_name>"
}

variable "vsphere_network" {
  description = "network name"
  default     = "<network_name>"
}

variable "vsphere_folder" {
  description = "path to create machine"
  default     = "<folder_name>"
}

variable "vsphere_resource_pool" {
  description = "root resource pool"
  default     = "<resource_pool_name>"
}

variable "vsphere_vm_template" {
  description = "virtual machine template"
  default     = "<template_name>"
}