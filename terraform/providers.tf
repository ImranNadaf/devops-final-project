terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "test26"
    storage_account_name = "imranstorage26"
    container_name       = "imrancontainer26"
    key                  = "cloudmaven-devops-assessment.tfstate"
  }
}

provider "azurerm" {
  features {}
}
