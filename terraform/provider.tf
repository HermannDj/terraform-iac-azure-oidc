terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
  }
  subscription_id = var.subscription_id

  # Configuration pour l'authentification OIDC
  use_oidc   = true
  oidc_token = var.oidc_token
  tenant_id  = var.tenant_id
  client_id  = var.client_id
}
