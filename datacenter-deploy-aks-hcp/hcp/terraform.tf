terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.29"
    }
  }

  required_version = ">= 1.0.11"

  provider_meta "hcp" {
    module_name = "hcp-consul"
  }
}