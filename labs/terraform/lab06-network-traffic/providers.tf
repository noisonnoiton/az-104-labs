# Azure CLI (az login) 자격 증명을 사용합니다.
# subscription_id 가 비면 현재 az CLI context 의 subscription 사용.

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id != "" ? var.subscription_id : null
  tenant_id       = var.tenant_id != "" ? var.tenant_id : null
}
