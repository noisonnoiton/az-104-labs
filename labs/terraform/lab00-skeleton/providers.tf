# Azure CLI 로그인(az login) 후 기본 자격 증명 체인을 사용합니다.
# subscription_id 를 비우면 현재 az CLI 컨텍스트의 구독이 사용됩니다.

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id != "" ? var.subscription_id : null
  tenant_id       = var.tenant_id != "" ? var.tenant_id : null
}
