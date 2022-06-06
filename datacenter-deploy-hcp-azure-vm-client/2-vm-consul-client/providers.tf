
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = ">= 0.23.1"
    }
  }

  required_version = ">= 1.0.11"
}

provider "azurerm" {
  features {}
}

provider "hcp" {}
