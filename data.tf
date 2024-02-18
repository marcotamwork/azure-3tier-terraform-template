data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "aks_mc" {
  name = "MC_example-${var.environment}_example-aks-${var.environment}_eastasia"
}
