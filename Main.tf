terraform {
  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.1"
    }

  }
}
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "simpsonTFC-rg" {
  name     = "simpsonTFC-rg"
  location = "EastUS"
  tags = {
    environment = "Dev-TFC"
  }
}

resource "azurerm_virtual_network" "simpsonTFC-vnet" {
  name                = "simpsonTFC-vnet"
  resource_group_name = azurerm_resource_group.simpsonTFC-rg.name
  location            = azurerm_resource_group.simpsonTFC-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "Dev-TFC"
  }
}

resource "azurerm_subnet" "simpsonTFC-subnet" {
  name                 = "simpsonTFC-subnet"
  resource_group_name  = azurerm_resource_group.simpsonTFC-rg.name
  virtual_network_name = azurerm_virtual_network.simpsonTFC-vnet.name
  address_prefixes     = ["10.123.1.0/24"]
}
resource "azurerm_subnet" "simpsonTFC-subnet2" {
  name                 = "simpsonTFC-subnet2"
  resource_group_name  = azurerm_resource_group.simpsonTFC-rg.name
  virtual_network_name = azurerm_virtual_network.simpsonTFC-vnet.name
  address_prefixes     = ["10.123.2.0/24"]
}
resource "azurerm_subnet" "simpsonTFC-subnet3" {
  name                 = "simpsonTFC-subnet3"
  resource_group_name  = azurerm_resource_group.simpsonTFC-rg.name
  virtual_network_name = azurerm_virtual_network.simpsonTFC-vnet.name
  address_prefixes     = ["10.123.3.0/24"]
}

resource "azurerm_network_security_group" "simpsonTFC-SG" {
  name                = "simpsonTFC-SG"
  location            = azurerm_resource_group.simpsonTFC-rg.location
  resource_group_name = azurerm_resource_group.simpsonTFC-rg.name

  tags = {
    environment = "Dev-TFC"
  }
}

resource "azurerm_network_security_rule" "simpsonTFC-rule" {
  name                        = "simpsonTFC-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.simpsonTFC-rg.name
  network_security_group_name = azurerm_network_security_group.simpsonTFC-SG.name

}
resource "azurerm_subnet_network_security_group_association" "simpsonTFC-SG-association" {
  subnet_id                 = azurerm_subnet.simpsonTFC-subnet.id
  network_security_group_id = azurerm_network_security_group.simpsonTFC-SG.id

}
resource "azurerm_public_ip" "simpsonTFC-pip" {
  name                = "simpsonTFC-pip"
  location            = azurerm_resource_group.simpsonTFC-rg.location
  resource_group_name = azurerm_resource_group.simpsonTFC-rg.name
  allocation_method   = "Static"

  tags = {
    environment = "Dev-TFC"
  }

}

resource "azurerm_network_interface" "simpsonTFC-nic" {
  name                = "simpsonTFC-nic"
  location            = azurerm_resource_group.simpsonTFC-rg.location
  resource_group_name = azurerm_resource_group.simpsonTFC-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.simpsonTFC-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.simpsonTFC-pip.id
  }

  tags = {
    environment = "Dev-TFC"
  }
}
resource "azurerm_network_interface" "simpsonTFC-nic2" {
  name                = "simpsonTFC-nic2"
  location            = azurerm_resource_group.simpsonTFC-rg.location
  resource_group_name = azurerm_resource_group.simpsonTFC-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.simpsonTFC-subnet2.id
    private_ip_address_allocation = "Dynamic"

  }

  tags = {
    environment = "Dev-TFC"
  }

}

resource "azurerm_storage_account" "simpsontfcstorage01" {
  name                     = "simpsontfcstorage01"
  location                 = azurerm_resource_group.simpsonTFC-rg.location
  resource_group_name      = azurerm_resource_group.simpsonTFC-rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_linux_virtual_machine" "simpsonTFC-linuxVM" {
  name                            = "simpsonTFC-linuxVM"
  resource_group_name             = azurerm_resource_group.simpsonTFC-rg.name
  location                        = azurerm_resource_group.simpsonTFC-rg.location
  size                            = "Standard_B1ms"
  admin_username                  = "setupadmin"
  admin_password                  = "C0r3t3k!C0r3t3k!"
  network_interface_ids           = [azurerm_network_interface.simpsonTFC-nic.id]
  computer_name                   = "simpsonTFC-linuxVM"
  disable_password_authentication = false
  custom_data                     = filebase64("customdata.tpl")

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
    storage_account_uri = azurerm_storage_account.simpsontfcstorage01.primary_blob_endpoint
  }

  admin_ssh_key {
    username   = "setupadmin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  provisioner "local-exec" {
    command = templatefile("windows-ssh-script.tpl", {
      hostname = self.public_ip_address,
      user     = "setupadmin",
    identityfile = "~/.ssh/id_rsa" })
    interpreter = ["PowerShell", "-Command"]
  }

  tags = {
    environment = "Dev-TFC"
  }
}

resource "azurerm_windows_virtual_machine" "simpsonTFC-windowsVM" {
  name                  = "simpsonTFC-windowsVM"
  resource_group_name   = azurerm_resource_group.simpsonTFC-rg.name
  location              = azurerm_resource_group.simpsonTFC-rg.location
  size                  = "Standard_B1ms"
  admin_username        = "setupadmin"
  admin_password        = "C0r3t3kC0r3t3k"
  network_interface_ids = [azurerm_network_interface.simpsonTFC-nic2.id]
  computer_name         = "simpsonTFC-WSVM"

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
    storage_account_uri = azurerm_storage_account.simpsontfcstorage01.primary_blob_endpoint
  }
  tags = {
    environment = "Dev-TFC"
  }
}

data "azurerm_public_ip" "simpsonTFC-ipdata" {
  name                = azurerm_public_ip.simpsonTFC-pip.name
  resource_group_name = azurerm_resource_group.simpsonTFC-rg.name
}

output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.simpsonTFC-linuxVM.name}: ${data.azurerm_public_ip.simpsonTFC-ipdata.ip_address}"
}
