resource "azurerm_virtual_network" "vnet_vm" {
  name                = var.vnet_vm_name
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network" "vnet_cluster" {
  name                = var.vnet_cluster_name
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_virtual_network_peering" "peer_vm" {
  name                      = var.peer_vm_name
  resource_group_name       = var.rg_name
  virtual_network_name      = azurerm_virtual_network.vnet_vm.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_cluster.id
}

resource "azurerm_virtual_network_peering" "peer_cluster" {
  name                      = var.peer_cluster_name
  resource_group_name       = var.rg_name
  virtual_network_name      = azurerm_virtual_network.vnet_cluster.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_vm.id
}

resource "azurerm_subnet" "subnet_vm" {
  name                 = var.subnet_vm_name
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet_vm.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet_cluster" {
  name                 = var.subnet_cluster_name
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet_cluster.name
  address_prefixes     = ["10.1.1.0/24"]
}

output "subnet_vm_id" {
  value = azurerm_subnet.subnet_vm.id
}

output "subnet_cluster_id" {
  value = azurerm_subnet.subnet_cluster.id
}