# Private Endpoint for Storage Account
resource "azurerm_private_endpoint" "this" {
  location            = azurerm_storage_account.example.location
  name                = "${azurerm_storage_account.example.name}_${var.environment}"
  resource_group_name = azurerm_storage_account.example.resource_group_name
  subnet_id           = azurerm_subnet.storage_subnet.id

  private_service_connection {
    is_manual_connection           = false
    name                           = "${azurerm_storage_account.example.name}_${var.environment}"
    private_connection_resource_id = azurerm_storage_account.example.id
    subresource_names              = ["blob"]
  }

  depends_on = [
    # azurerm_storage_container.example,
    azurerm_private_dns_zone_virtual_network_link.private_links,
    azurerm_private_dns_zone_virtual_network_link.public_endpoints,
  ]
}
