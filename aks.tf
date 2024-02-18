# AKS
resource "azurerm_kubernetes_cluster" "main" {
  name                = "example-aks-${var.environment}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "example-k8s-${var.environment}"

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.0.2.10"
    service_cidr   = "10.0.2.0/24"
  }

  default_node_pool {
    name                = "default"
    vm_size             = "Standard_D2_v5"
    vnet_subnet_id      = azurerm_subnet.node_subnet.id
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    node_count          = 1
    min_count           = 1
    max_count           = 2

    temporary_name_for_rotation = "tmpnode01"

  }

  identity {
    type = "SystemAssigned"
  }

  # oms_agent {
  #   log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_insights.id
  # }


  tags = {
    Environment = "${var.environment}"
  }
}

# Log Analytics for AKS
# resource "azurerm_log_analytics_workspace" "aks_insights" {
#   name                = "example-aks-${var.environment}-log"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
#   retention_in_days   = 30
# }

# Data Export to Storage from Log Analytics
# resource "azurerm_log_analytics_data_export_rule" "example" {
#   name                    = "example-aks-${var.environment}-log-export"
#   resource_group_name     = azurerm_resource_group.example.name
#   workspace_resource_id   = azurerm_log_analytics_workspace.aks_insights.id
#   destination_resource_id = azurerm_storage_account.example.id
#   table_names             = ["ContainerLog"]
#   enabled                 = true
# }


output "client_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.client_certificate

  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.main.kube_config_raw

  sensitive = true
}
