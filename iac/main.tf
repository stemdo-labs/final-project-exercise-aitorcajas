terraform {
  required_version = ">= 1.5.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {

  }
}

resource "azurerm_virtual_network" "vnet_vm" {
  name                = "vnet-vm"
  location            = "West Europe"
  resource_group_name = "rg-acajas-dvfinlab"
  address_space       = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network" "vnet_cluster" {
  name                = "vnet-cluster"
  location            = "West Europe"
  resource_group_name = "rg-acajas-dvfinlab"
  address_space       = ["10.0.2.0/24"]
}

resource "azurerm_virtual_network_peering" "peer_vm" {
  name                      = "peer-vm"
  resource_group_name       = "rg-acajas-dvfinlab"
  virtual_network_name      = azurerm_virtual_network.vnet_vm.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_cluster.id
}

resource "azurerm_virtual_network_peering" "peer_cluster" {
  name                      = "peer-cluster"
  resource_group_name       = "rg-acajas-dvfinlab"
  virtual_network_name      = azurerm_virtual_network.vnet_cluster.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_vm.id
}

resource "azurerm_subnet" "subnet_vm" {
  name                 = "subnet-vm"
  resource_group_name  = "rg-acajas-dvfinlab"
  virtual_network_name = azurerm_virtual_network.vnet_vm.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet_cluster" {
  name                 = "subnet-cluster"
  resource_group_name  = "rg-acajas-dvfinlab"
  virtual_network_name = "vnet-cluster"
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic_1" {
  name                = "nic-vmbd-1"
  location            = "West Europe"
  resource_group_name = "rg-acajas-dvfinlab"

  ip_configuration {
    name                          = "ip-configuration-1"
    subnet_id                     = azurerm_subnet.subnet_vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic_2" {
  name                = "nic-vmbd-2"
  location            = "West Europe"
  resource_group_name = "rg-acajas-dvfinlab"

  ip_configuration {
    name                          = "ip-configuration-2"
    subnet_id                     = azurerm_subnet.subnet_vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vm_1" {
  name                  = "vm-1"
  location              = "West Europe"
  resource_group_name   = "rg-acajas-dvfinlab"
  network_interface_ids = [azurerm_network_interface.nic_1.id]
  vm_size               = "Standard_B1ms"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine" "vm_2" {
  name                  = "vm-2"
  location              = "West Europe"
  resource_group_name   = "rg-acajas-dvfinlab"
  network_interface_ids = [azurerm_network_interface.nic_2.id]
  vm_size               = "Standard_B1ms"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks"
  location              = "West Europe"
  resource_group_name   = "rg-acajas-dvfinlab"
  dns_prefix          = "dns-aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.subnet_cluster.id
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_container_registry" "acajascr" {
  name                     = "acajascr"
  location              = "West Europe"
  resource_group_name   = "rg-acajas-dvfinlab"
  sku                      = "Premium"
  admin_enabled            = false
}