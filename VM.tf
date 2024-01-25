# Create a Linux virtual machine
resource "azurerm_linux_virtual_machine" "msimpson-linuxVM1" {
  name                            = "msimpson-linuxVM1"
  resource_group_name             = data.azurerm_resource_group.msimpson.name
  location                        = var.location
  size                            = "Standard_B1ms"
  admin_username                  = "setupadmin"
  admin_password                  = azurerm_key_vault_secret.msimpson-LinuxKV.value
  network_interface_ids           = [azurerm_network_interface.msimpson-nic.id, azurerm_network_interface.msimpson-niclb.id]
  availability_set_id             = azurerm_availability_set.msimpson-avset.id
  computer_name                   = "msimpson-linuxVM1"
  disable_password_authentication = false
  custom_data                     = filebase64("customdata.tpl")

  depends_on = [
    azurerm_network_interface.msimpson-nic,
    azurerm_key_vault_secret.msimpson-LinuxKV
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"

  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.msimpsonstorage02.primary_blob_endpoint
  }

  admin_ssh_key {
    username   = "setupadmin"
    public_key = file("~/.ssh/msimpsonkey.pub")
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-script.tpl", {
      hostname = self.public_ip_address,
      user     = "setupadmin",
    identityfile = "~/.ssh/msimpsonkey" })
    interpreter = var.host_os == "windows" ? ["PowerShell", "-Command"] : ["bash", "-c"]
  }

  tags = {
    environment = "Dev-TFC"
  }
}

# Create a Windows virtual machine
resource "azurerm_windows_virtual_machine" "msimpson-windowsVM" {
  name                  = "msimpson-windowsVM"
  resource_group_name   = data.azurerm_resource_group.msimpson.name
  location              = var.location
  size                  = "Standard_B1ms"
  admin_username        = "setupadmin"
  admin_password        = azurerm_key_vault_secret.msimpson-WindowsKV.value
  network_interface_ids = [azurerm_network_interface.msimpson-nic2.id]
  computer_name         = "msimpson-WSVM"

  depends_on = [
    azurerm_network_interface.msimpson-nic2,
    azurerm_key_vault_secret.msimpson-WindowsKV
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"

  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.msimpsonstorage02.primary_blob_endpoint
  }
  tags = {
    environment = "Dev-TFC"
  }
}