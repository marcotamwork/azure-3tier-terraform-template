# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.79.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "example-tf"
    storage_account_name = "exampletf"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

# Configure the Azure provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  storage_use_azuread        = true
  skip_provider_registration = true
}
