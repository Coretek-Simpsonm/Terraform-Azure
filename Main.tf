# Start Terraform code
terraform {

  # Declare the Required Providers
  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

# Configure the Providers
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

}
#declare Resource Group
data "azurerm_resource_group" "msimpson" {
  name = "msimpson-sandbox"
}

output "msimpson" {
  value = "msimpson-sandbox"
}
# Azure Key Vault Provider
data "azurerm_client_config" "current" {}


# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = data.azurerm_resource_group.msimpson.name
  }

  byte_length = 8
}

#create an availability set
resource "azurerm_availability_set" "msimpson-avset" {
  name                         = "msimpson-avset"
  location                     = var.location
  resource_group_name          = data.azurerm_resource_group.msimpson.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags = {
    environment = "Dev-TFC"
  }
}
output "AVSET1" {
  value = azurerm_availability_set.msimpson-avset.id
}
# Create a virtual network
resource "azurerm_virtual_network" "msimpson-ivnet" {
  name                = "msimpson-ivnet"
  resource_group_name = data.azurerm_resource_group.msimpson.name
  location            = var.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "Dev-TFC"
  }
}
resource "azurerm_virtual_network" "msimpson-evnet" {
  name                = "msimpson-evnet"
  resource_group_name = data.azurerm_resource_group.msimpson.name
  location            = var.location
  address_space       = ["10.123.1.0/24"]

  tags = {
    environment = "Dev-TFC"
  }
}
# Create subnets
resource "azurerm_subnet" "msimpson-subnet" {
  name                 = "msimpson-subnet"
  resource_group_name  = data.azurerm_resource_group.msimpson.name
  virtual_network_name = azurerm_virtual_network.msimpson-evnet.name
  address_prefixes     = ["10.123.1.0/24"]
}
resource "azurerm_subnet" "msimpson-subnet2" {
  name                 = "msimpson-subnet2"
  resource_group_name  = data.azurerm_resource_group.msimpson.name
  virtual_network_name = azurerm_virtual_network.msimpson-ivnet.name
  address_prefixes     = ["10.123.2.0/24"]
}
resource "azurerm_subnet" "msimpson-subnet3" {
  name                 = "msimpson-subnet3"
  resource_group_name  = data.azurerm_resource_group.msimpson.name
  virtual_network_name = azurerm_virtual_network.msimpson-ivnet.name
  address_prefixes     = ["10.123.3.0/24"]
}

# Create a network security group
resource "azurerm_network_security_group" "msimpson-SG" {
  name                = "msimpson-SG"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.msimpson.name

  tags = {
    environment = "Dev-TFC"
  }
}

# Create a network security group rule
resource "azurerm_network_security_rule" "msimpson-rule" {
  name                        = "msimpson-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.msimpson.name
  network_security_group_name = azurerm_network_security_group.msimpson-SG.name

}

# Associate the network security group with the subnet
resource "azurerm_subnet_network_security_group_association" "msimpson-SG-association" {
  subnet_id                 = azurerm_subnet.msimpson-subnet.id
  network_security_group_id = azurerm_network_security_group.msimpson-SG.id

}

# Create a public IP address
resource "azurerm_public_ip" "msimpson-pip" {
  name                = "msimpson-pip"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.msimpson.name
  allocation_method   = "Static"

  tags = {
    environment = "Dev-TFC"
  }

}


# Create a network interface
resource "azurerm_network_interface" "msimpson-nic" {
  name                = "msimpson-nic"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.msimpson.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.msimpson-subnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.msimpson-pip.id
  }

  tags = {
    environment = "Dev-TFC"
  }
}
resource "azurerm_network_interface" "msimpson-nic2" {
  name                = "msimpson-nic2"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.msimpson.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.msimpson-subnet2.id
    private_ip_address_allocation = "Dynamic"

  }


  tags = {
    environment = "Dev-TFC"
  }

}
resource "azurerm_network_interface" "msimpson-nic3" {
  name                = "msimpson-nic3"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.msimpson.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.msimpson-subnet2.id
    private_ip_address_allocation = "Dynamic"

  }


  tags = {
    environment = "Dev-TFC"
  }

}
resource "azurerm_network_interface" "msimpson-niclb" {
  name                = "msimpson-niclb"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.msimpson.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.msimpson-subnet3.id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.msimpson-lbpip.id
  }

  tags = {
    environment = "Dev-TFC"
  }
}
# Create a storage account
resource "azurerm_storage_account" "msimpsonstorage02" {
  name                     = "msimp${random_id.random_id.hex}"
  location                 = var.location
  resource_group_name      = data.azurerm_resource_group.msimpson.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
# Create Azure Key vault
resource "azurerm_key_vault" "msimpsom-keyvault" {
  name                       = "msimpson-keyvault"
  location                   = var.location
  resource_group_name        = data.azurerm_resource_group.msimpson.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  sku_name                   = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "Get",
    ]
    secret_permissions = [
      "Get", "Backup", "Restore", "List", "Set", "Delete", "Purge", "Recover"
    ]
    storage_permissions = [
      "Get",
    ]
  }
}

#Create secrets in the key vault
resource "azurerm_key_vault_secret" "msimpson-LinuxKV" {
  name         = "msimpson-LinuxKV"
  value        = "C0r3t3k!C0r3t3k!"
  key_vault_id = azurerm_key_vault.msimpsom-keyvault.id
  depends_on   = [azurerm_key_vault.msimpsom-keyvault]

}
resource "azurerm_key_vault_secret" "msimpson-WindowsKV" {
  name         = "msimpson-WindowsKV"
  value        = "C0r3t3k!C0r3t3k!"
  key_vault_id = azurerm_key_vault.msimpsom-keyvault.id
  depends_on   = [azurerm_key_vault.msimpsom-keyvault]

}
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
resource "azurerm_linux_virtual_machine" "msimpson-linuxVM2" {
  name                            = "msimpson-linuxVM2"
  resource_group_name             = data.azurerm_resource_group.msimpson.name
  location                        = var.location
  size                            = "Standard_B1ms"
  admin_username                  = "setupadmin"
  admin_password                  = azurerm_key_vault_secret.msimpson-LinuxKV.value
  network_interface_ids           = [azurerm_network_interface.msimpson-nic3.id]
  availability_set_id             = azurerm_availability_set.msimpson-avset.id
  computer_name                   = "msimpson-linuxVM2"
  disable_password_authentication = false
  custom_data                     = filebase64("customdata.tpl")

  depends_on = [
    azurerm_network_interface.msimpson-nic3,
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

# Create a data source to get the public IP address
data "azurerm_public_ip" "msimpson-ipdata" {
  name                = azurerm_public_ip.msimpson-pip.name
  resource_group_name = data.azurerm_resource_group.msimpson.name
}

# Output the public IP address
#output "public_ip_address" {
#  value = "${azurerm_linux_virtual_machine.msimpson-linuxVM1.name}: ${data.azurerm_public_ip.msimpson-ipdata.ip_address}"
#}
