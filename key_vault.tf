# Key Vault
resource "azurerm_key_vault" "dbv2" {
  name                        = "example-dbkey-${var.environment}"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true

  sku_name = "standard"

  # Access Policy for devops
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore",
      "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign", "Purge",
      "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"
    ]

    secret_permissions = [
      "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]

    storage_permissions = [
      "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge",
      "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
    ]
  }

  # Access Policy for UAI
  access_policy {
    tenant_id = azurerm_user_assigned_identity.prod.tenant_id
    object_id = azurerm_user_assigned_identity.prod.principal_id

    key_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore",
      "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign", "Purge",
      "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"
    ]

    secret_permissions = [
      "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]

    storage_permissions = [
      "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge",
      "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
    ]
  }

  # Access Policy for Storage Account
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_storage_account.example.identity.0.principal_id

    key_permissions    = ["Get", "Create", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
    secret_permissions = ["Get"]
  }

}

# Key
resource "azurerm_key_vault_key" "dbv2" {
  name         = "example-dbkey-${var.environment}"
  key_vault_id = azurerm_key_vault.dbv2.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P3Y"
    notify_before_expiry = "P29D"
  }

  depends_on = [azurerm_key_vault.dbv2]
}
