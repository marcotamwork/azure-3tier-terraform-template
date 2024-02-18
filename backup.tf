# Backup Vault
resource "azurerm_data_protection_backup_vault" "example" {
  name                = "example-backup-${var.environment}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  datastore_type      = "VaultStore"
  redundancy          = "GeoRedundant"
  identity {
    type = "SystemAssigned"
  }
}

# Role Assignment for Storage BackUp
resource "azurerm_role_assignment" "storage_backup" {
  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Account Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.example.identity[0].principal_id
}

# Backup policy for Storage Account
resource "azurerm_data_protection_backup_policy_blob_storage" "storage_policy" {
  name               = "example-backup-${var.environment}"
  vault_id           = azurerm_data_protection_backup_vault.example.id
  retention_duration = "P30D"
}

# Backup for Storage Account
resource "azurerm_data_protection_backup_instance_blob_storage" "example" {
  name               = "example-backup-storage-${var.environment}"
  vault_id           = azurerm_data_protection_backup_vault.example.id
  location           = azurerm_resource_group.example.location
  storage_account_id = azurerm_storage_account.example.id
  backup_policy_id   = azurerm_data_protection_backup_policy_blob_storage.storage_policy.id

  depends_on = [azurerm_role_assignment.storage_backup]
}