# Azure CLI (az login) 자격 증명을 사용합니다.

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id != "" ? var.subscription_id : null
  tenant_id       = var.tenant_id != "" ? var.tenant_id : null
}
