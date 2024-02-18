
# Create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "${var.environment}"
  }
}

### CIDR "10.0.2.0/24" is delegated for AKS services

# Subnet for AKS node pool
resource "azurerm_subnet" "node_subnet" {
  name                 = "example-node-subnet-${var.environment}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.namesubnet ids to secure the storage account
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

# Subnet for Storage
resource "azurerm_subnet" "storage_subnet" {
  name                 = "example-storage-${var.environment}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.3.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

# Subnet for MySQL
resource "azurerm_subnet" "db_subnet" {
  name                 = "example-db-subnet-${var.environment}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.4.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}
