# Container Registry
resource "azurerm_container_registry" "example" {
  name                = "ExampleRegistry${var.environment}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Basic"
}

# Role Assignment for AKS
resource "azurerm_role_assignment" "example_role" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.example.id
  skip_service_principal_aad_check = true
}
