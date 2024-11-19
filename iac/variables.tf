variable "rg_name" {
  type        = string
  description = "Nombre del grupo de recursos"
}

variable "location" {
  type = string
  description = "Localización"
}

variable "vnet_vm_name" {
  type = string
  description = "Nombre de la vnet de las máquinas virtuales"
  default = "vnet-vm"
}

variable "vnet_cluster_name" {
  type = string
  description = "Nombre de la vnet del cluster"
  default = "vnet-cluster"
}

variable "subnet_vm_name" {
  type = string
  description = "Nombre de la subnet de las máquinas virtuales"
  default = "subnet-vm"
}

variable "subnet_cluster_name" {
  type = string
  description = "Nombre de la subnet del cluster"
  default = "subnet-cluster"
}

variable "peer_vm_name" {
  type = string
  default = "peer-vm"
}

variable "peer_cluster_name" {
  type = string
  default = "peer-cluster"
}

variable "cluster_name" {
  type = string
  description = "Nombre del cluster"
  default = "aks"
}

variable "dns_cluster_prefix" {
  type = string
  description = "Nombre del DNS del cluster"
  default = "dns-aks"
}

variable "cr_name" {
  type = string
  description = "Nombre del Container Registry"
  default = "acajascr"
}

variable "con_name" {
  type = string
  description = "Nombre del contenedor"
  default = "con-acajas"
}

variable "sa_name" {
  type = string
  description = "Nombre de la cuenta de almacenamiento"
}