# User Assigned Identity
resource "azurerm_user_assigned_identity" "prod" {
  name                = "example-uai-${var.environment}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}
