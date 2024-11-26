resource "azurerm_virtual_network" "vnet_vm" {
  name                = var.vnet_vm_name
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network" "vnet_cluster" {
  name                = var.vnet_cluster_name
  location            = var.location_cluster
  resource_group_name = var.rg_name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_virtual_network_peering" "peer_vm" {
  name                      = var.peer_vm_name
  resource_group_name       = var.rg_name
  virtual_network_name      = azurerm_virtual_network.vnet_vm.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_cluster.id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "peer_cluster" {
  name                      = var.peer_cluster_name
  resource_group_name       = var.rg_name
  virtual_network_name      = azurerm_virtual_network.vnet_cluster.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_vm.id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
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

resource "azurerm_network_security_group" "nsg_vm" {
  name                = var.nsg_vm_name
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsga" {
  subnet_id                 = azurerm_subnet.subnet_vm.id
  network_security_group_id = azurerm_network_security_group.nsg_vm.id
}

resource "azurerm_public_ip" "pip" {
  name                = var.pip_name
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "aks_nsg" {
  name                = var.aks_nsg_name
  location            = var.location_cluster
  resource_group_name = var.rg_name

  security_rule {
    name                       = "AllowPostgresFromK8s"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsga_aks" {
  subnet_id                 = azurerm_subnet.subnet_cluster.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

### OUTPUTS

output "subnet_vm_id" {
  value = azurerm_subnet.subnet_vm.id
}

output "subnet_cluster_id" {
  value = azurerm_subnet.subnet_cluster.id
}

output "pip_id" {
  value = azurerm_public_ip.pip.id
}
