# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "example-${var.environment}"
  location = "East Asia"

  tags = {
    Environment = "${var.environment}"
  }
}
