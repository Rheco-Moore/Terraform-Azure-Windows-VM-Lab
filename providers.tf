// Configure the Azure provider 
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
   
  cloud {
    organization = "rheco-moore-org"
    workspaces {
      name = "learn-terraform-azure"
    }
  }

}
    
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
    
 