# MySQL Database Server
resource "azurerm_mysql_flexible_server" "main" {
  name                = "example-mysqlserver-${var.environment}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  delegated_subnet_id = azurerm_subnet.db_subnet.id
  private_dns_zone_id = azurerm_private_dns_zone.database.id

  zone                   = "1"
  administrator_login    = "gtadmin"
  administrator_password = "ug0*+Cb62bU,!Vq8-EvMrCLibNPcE@#v"

  sku_name = "GP_Standard_D2ads_v5"

  storage {
    size_gb           = 20
    auto_grow_enabled = true
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.prod.id]
  }

  customer_managed_key {
    key_vault_key_id                  = azurerm_key_vault_key.dbv2.id
    primary_user_assigned_identity_id = azurerm_user_assigned_identity.prod.id
  }

  version = "5.7"

  backup_retention_days = 30 # default 7 days

  high_availability {
    mode                      = "ZoneRedundant"
    standby_availability_zone = 2
  }

  tags = {
    Environment = "${var.environment}"
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.db_links]
}


resource "azurerm_mysql_flexible_server_active_directory_administrator" "me" {
  server_id   = azurerm_mysql_flexible_server.main.id
  identity_id = azurerm_user_assigned_identity.prod.id
  login       = "sqladmin"
  object_id   = data.azurerm_client_config.current.client_id
  tenant_id   = data.azurerm_client_config.current.tenant_id
}

# MySQL Database Server Parameters
resource "azurerm_mysql_flexible_server_configuration" "audit_log_enabled" {
  name                = "audit_log_enabled"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_mysql_flexible_server.main.name
  value               = "ON"
}

resource "azurerm_mysql_flexible_server_configuration" "audit_log_events" {
  name                = "audit_log_events"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_mysql_flexible_server.main.name
  value               = "CONNECTION,GENERAL"
}

# resource "azurerm_mysql_flexible_server_configuration" "audit_log_include_users" {
#   name                = "audit_log_include_users"
#   resource_group_name = azurerm_resource_group.example.name
#   server_name         = azurerm_mysql_flexible_server.example.name
#   value               = "gtadmin"
# }


# MySQL Database Diagnostic Setting
resource "azurerm_monitor_diagnostic_setting" "example" {
  name               = "auditlog"
  target_resource_id = azurerm_mysql_flexible_server.main.id
  storage_account_id = azurerm_storage_account.example.id

  enabled_log {
    category = "MySqlAuditLogs"

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false
    retention_policy {
      enabled = false
    }
  }

  depends_on = [
    azurerm_mysql_flexible_server_configuration.audit_log_enabled, azurerm_mysql_flexible_server_configuration.audit_log_events
  ]
}

# MySQL Database
resource "azurerm_mysql_flexible_database" "main" {
  name                = "example-mysqldb-${var.environment}"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}



# MySQL Network
# resource "azurerm_mysql_virtual_network_rule" "main" {
#   name                = "example-mysql-vnet-rule-${var.environment}"
#   resource_group_name = azurerm_resource_group.example.name
#   server_name         = azurerm_mysql_flexible_server.main.name
#   subnet_id           = azurerm_subnet.db_subnet.id
# }
