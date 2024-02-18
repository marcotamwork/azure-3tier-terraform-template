# Storage
resource "azurerm_storage_account" "example" {
  name                     = "example${var.environment}storage"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  large_file_share_enabled      = "false"
  public_network_access_enabled = "true"
  # blob_properties {
  #   change_feed_enabled      = "true"
  #   last_access_time_enabled = "true"
  #   versioning_enabled       = "true"
  #   delete_retention_policy {
  #     days = 35
  #   }
  #   restore_policy {
  #     days = 30
  #   }
  # }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      customer_managed_key
    ]
  }

}

# Network Rules for Storage Account
resource "azurerm_storage_account_network_rules" "example" {
  storage_account_id         = azurerm_storage_account.example.id
  default_action             = "Allow"
  ip_rules                   = ["103.6.176.130"]
  virtual_network_subnet_ids = [azurerm_subnet.storage_subnet.id, azurerm_subnet.db_subnet.id]
  bypass                     = ["Metrics"]
}

# Data Encrytion for Storage Account
resource "azurerm_storage_account_customer_managed_key" "storage_key" {
  storage_account_id = azurerm_storage_account.example.id
  key_vault_id       = azurerm_key_vault.dbv2.id
  key_name           = azurerm_key_vault_key.dbv2.name
}

# Storage Blob Container
resource "azurerm_storage_container" "example" {
  name                  = "example-blob"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "blob"

}

# Storage Lifecycle for AKS container log
resource "azurerm_storage_management_policy" "example_storage" {
  storage_account_id = azurerm_storage_account.example.id

  rule {
    name    = "aks-log-stprage-lifecycle"
    enabled = true
    filters {
      prefix_match = ["am-containerlog/WorkspaceResourceId=/subscriptions"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
        delete_after_days_since_modification_greater_than          = 2555
      }
      # snapshot {
      #   change_tier_to_archive_after_days_since_creation = 90
      #   change_tier_to_cool_after_days_since_creation    = 23
      #   delete_after_days_since_creation_greater_than    = 31
      # }
      version {
        change_tier_to_archive_after_days_since_creation = 15
        change_tier_to_cool_after_days_since_creation    = 7
        delete_after_days_since_creation                 = 30
      }
    }
  }
}
