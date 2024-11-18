terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.94.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {

  }
}

module "networks" {
  source              = "./modules/networks"
  rg_name             = var.rg_name
  location            = var.location
  vnet_vm_name        = var.vnet_vm_name
  vnet_cluster_name   = var.vnet_cluster_name
  peer_vm_name        = var.peer_vm_name
  peer_cluster_name   = var.peer_cluster_name
  subnet_cluster_name = var.subnet_cluster_name
  subnet_vm_name      = var.subnet_vm_name
}

module "vms" {
  source = "./modules/vms"
  rg_name             = var.rg_name
  location            = var.location
  subnet_vm_id = module.networks.subnet_vm_id
  depends_on = [ module.networks ]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = var.dns_cluster_prefix

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_B2s"
    vnet_subnet_id = module.networks.subnet_cluster_id
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_container_registry" "acajascr" {
  name                = var.cr_name
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "Premium"
  admin_enabled       = false
}