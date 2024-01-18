#Create Azure Site Recover Vault
resource "azurerm_recovery_services_vault" "msimpsonASR" {
  name                = "msimpsonASR"
  location            = azurerm_resource_group.msimpson.location
  resource_group_name = azurerm_resource_group.msimpson.name
  sku                 = "Standard"
  soft_delete_enabled = true
  # Remove the invalid attribute
  # purge_protection_enabled = false
  tags = {
    environment = "Dev-TFC"
  }
}
#Create Azure Recovery Services Vault Backup Policy
resource "azurerm_backup_policy_vm" "msimpsonASR-vmbackuppolicy" {
  name                = "msimpsonASR-vmbackuppolicy"
  resource_group_name = azurerm_resource_group.msimpson.name
  recovery_vault_name = azurerm_recovery_services_vault.msimpsonASR.name

  timezone = "UTC"
  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }

  retention_weekly {
    count    = 42
    weekdays = ["Sunday"]
  }

  retention_monthly {
    count    = 7
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }

  retention_yearly {
    count    = 77
    weekdays = ["Sunday"]
    weeks    = ["Last"]
    months   = ["January"]
  }

}
