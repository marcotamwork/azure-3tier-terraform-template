# Security Group
resource "azurerm_network_security_group" "aks" {
  name                = "example-sg-aks-${var.environment}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "AllowMySQL"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "10.0.2.0"
    destination_address_prefix = "10.0.4.0"
  }
  tags {
    environment = "${var.environment}"
  }
}

# resource "azurerm_network_security_rule" "aks" {
#   name                        = "example-sg-aks-${var.environment}"
#   priority                    = 100
#   direction                   = "Outbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = azurerm_subnet.storage_subnet.address_prefixes[0]
#   destination_address_prefix  = azurerm_subnet.db_subnet.address_prefixes[0]
#   resource_group_name         = azurerm_resource_group.example.name
#   network_security_group_name = azurerm_network_security_group.aks.name
# }



