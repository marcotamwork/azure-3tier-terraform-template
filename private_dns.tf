resource "azurerm_private_dns_zone" "private_links" {
  name                = "privatelink.${var.environment}.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "public_endpoints" {
  name                = "${var.environment}.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "database" {
  name                = "${var.environment}.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "db_links" {
  name                  = "${azurerm_virtual_network.example.name}-${var.environment}.com"
  private_dns_zone_name = azurerm_private_dns_zone.database.name
  resource_group_name   = azurerm_resource_group.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_links" {
  name                  = "${azurerm_virtual_network.example.name}_${var.environment}_private"
  private_dns_zone_name = azurerm_private_dns_zone.private_links.name
  resource_group_name   = azurerm_resource_group.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "public_endpoints" {
  name                  = "${azurerm_virtual_network.example.name}_${var.environment}_public"
  private_dns_zone_name = azurerm_private_dns_zone.public_endpoints.name
  resource_group_name   = azurerm_resource_group.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_private_dns_a_record" "private" {
  name                = azurerm_storage_account.example.name
  records             = [azurerm_private_endpoint.this.private_service_connection[0].private_ip_address]
  resource_group_name = azurerm_private_dns_zone.private_links.resource_group_name
  zone_name           = azurerm_private_dns_zone.private_links.name
  ttl                 = 60
}

resource "azurerm_private_dns_cname_record" "public" {
  name                = azurerm_storage_account.example.name
  record              = azurerm_private_dns_a_record.private.fqdn
  resource_group_name = azurerm_private_dns_a_record.private.resource_group_name
  zone_name           = azurerm_private_dns_zone.public_endpoints.name
  ttl                 = 60
}
