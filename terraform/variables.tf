variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "terraform-iac-rg"
}

variable "location" {
  description = "The Azure region to deploy resources"
  type        = string
  default     = "Canada Central"
}

variable "acr_name" {
  description = "The name of the Azure Container Registry"
  type        = string
  default     = "myacr12345"
}

variable "app_service_name" {
  description = "The name of the Azure App Service"
  type        = string
  default     = "my-app-service-plan"
}

variable "app_service_plan_name" {
  description = "The name of the Azure App Service"
  type        = string
  default     = "my-app-service"
}

variable "subscription_id" {
  description = "The Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "The Azure AD Tenant ID"
  type        = string
}

variable "client_id" {
  description = "The Azure AD Application (client) ID"
  type        = string
}

variable "oidc_token" {
  description = "The OIDC token for authentication"
  type        = string
  sensitive   = true
}
