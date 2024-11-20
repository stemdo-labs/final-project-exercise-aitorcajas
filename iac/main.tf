terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.94.0"
    }
  }
  required_version = ">= 1.1.0"

  backend "azurerm" {
    storage_account_name = "staacajasdvfinlab"
    container_name       = "tfstatecont"
    key                  = "terraform.tfstate"
    resource_group_name  = "rg-acajas-dvfinlab"
  }
}

provider "azurerm" {
  features {

  }
}

module "networks" {
  source              = "./modules/networks"
  rg_name             = var.rg_name
  location            = var.location
  location_cluster    = var.location_cluster
  vnet_vm_name        = var.vnet_vm_name
  vnet_cluster_name   = var.vnet_cluster_name
  peer_vm_name        = var.peer_vm_name
  peer_cluster_name   = var.peer_cluster_name
  subnet_cluster_name = var.subnet_cluster_name
  subnet_vm_name      = var.subnet_vm_name
  nsg_vm_name         = var.nsg_vm_name
  pip_name            = var.pip_name
}

module "vms" {
  source       = "./modules/vms"
  rg_name      = var.rg_name
  location     = var.location
  subnet_vm_id = module.networks.subnet_vm_id
  pip_id       = module.networks.pip_id
  nic_bd_name  = var.nic_bd_name
  nic_dr_name  = var.nic_dr_name
  vm_bd_name   = var.vm_bd_name
  vm_dr_name   = var.vm_dr_name
  depends_on   = [module.networks]
}

# resource "azurerm_kubernetes_cluster" "aks" {
#   name                = var.cluster_name
#   location            = var.location_cluster
#   resource_group_name = var.rg_name
#   dns_prefix          = var.dns_cluster_prefix

#   default_node_pool {
#     name           = "default"
#     node_count     = 1
#     vm_size        = "Standard_B2s"
#     vnet_subnet_id = module.networks.subnet_cluster_id
#   }

#   identity {
#     type = "SystemAssigned"
#   }
# }

resource "azurerm_container_registry" "acajascr" {
  name                = var.cr_name
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "Premium"
  admin_enabled       = false
}

## commit de prueba