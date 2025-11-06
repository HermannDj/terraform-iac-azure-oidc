terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-backend-rg"
    storage_account_name = "tfstatebackendhermann"
    container_name       = "terraform-tfstate"
    key                 = "terraform.tfstate"
    use_oidc           = true
    subscription_id    = "1cc729ee-fbd5-4b09-95e8-64fa2a6f2b8b"
  }
}