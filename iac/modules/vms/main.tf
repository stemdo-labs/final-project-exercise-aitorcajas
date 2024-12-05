resource "azurerm_network_interface" "nic_bd" {
  name                = var.nic_bd_name
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "ip-configuration-bd"
    subnet_id                     = "/subscriptions/86f76907-b9d5-46fa-a39d-aff8432a1868/resourceGroups/final-project-common/providers/Microsoft.Network/virtualNetworks/vnet-common-bootcamp/subnets/sn-acajas"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.30.4"
    public_ip_address_id          = var.pip_id
  }
}

# resource "azurerm_network_interface" "nic_dr" {
#   name                = var.nic_dr_name
#   location            = var.location
#   resource_group_name = var.rg_name

#   ip_configuration {
#     name                          = "ip-configuration-dr"
#     subnet_id                     = "/subscriptions/86f76907-b9d5-46fa-a39d-aff8432a1868/resourceGroups/final-project-common/providers/Microsoft.Network/virtualNetworks/vnet-common-bootcamp/subnets/sn-acajas"
#     private_ip_address_allocation = "Static"
#     private_ip_address = "10.0.30.5"
#     public_ip_address_id          = var.pip_id
#   }
# }

resource "azurerm_virtual_machine" "vm_bd" {
  name                  = var.vm_bd_name
  location              = var.location
  resource_group_name   = var.rg_name
  network_interface_ids = [azurerm_network_interface.nic_bd.id]
  vm_size               = "Standard_B1ms"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk-bd"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  delete_os_disk_on_termination = true

  os_profile {
    computer_name  = "hostname"
    admin_username = var.vm_user
    admin_password = var.vm_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# resource "azurerm_virtual_machine" "vm_dr" {
#   name                  = var.vm_dr_name
#   location              = var.location
#   resource_group_name   = var.rg_name
#   network_interface_ids = [azurerm_network_interface.nic_dr.id]
#   vm_size               = "Standard_B1ms"

#   storage_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }

#   storage_os_disk {
#     name              = "myosdisk-dr"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }

#   delete_os_disk_on_termination = true

#   os_profile {
#     computer_name  = "hostname"
#     admin_username = "acajas"
#     admin_password = "Password1234!"
#   }

#   os_profile_linux_config {
#     disable_password_authentication = false
#   }
# }
#