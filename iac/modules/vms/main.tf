resource "azurerm_network_interface" "nic_bd" {
  name                = var.nic_bd_name
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "ip-configuration-bd"
    subnet_id                     = var.subnet_vm_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic_dr" {
  name                = var.nic_dr_name
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "ip-configuration-dr"
    subnet_id                     = var.subnet_vm_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.pip_id
  }
}

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
    admin_username = "acajasbd"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine" "vm_dr" {
  name                  = var.vm_dr_name
  location              = var.location
  resource_group_name   = var.rg_name
  network_interface_ids = [azurerm_network_interface.nic_dr.id]
  vm_size               = "Standard_B1ms"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk-dr"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  delete_os_disk_on_termination = true

  os_profile {
    computer_name  = "hostname"
    admin_username = "acajas"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "null_resource" "generate_inventory" {
  provisioner "local-exec" {
    command = <<EOT
      echo -e "[bd]\nvm-bd ansible_host=${azurerm_network_interface.nic_bd.ip_configuration[0].private_ip_address} ansible_user=acajasbd ansible_ssh_pass=Password1234! ansible_become=true ansible_become_method=sudo ansible_become_user=root" > ../ansible/inventory.ini
    EOT
  }
}
