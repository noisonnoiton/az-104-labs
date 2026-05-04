#==============================================================================
# Lab 09a - PaaS Web App (Container) Deployment
# 복사: cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 는 민감 정보가 담길 수 있어 공개 저장소에 커밋하지 마세요.
#==============================================================================

# 필수: 강사가 알려준 본인 RG 이름
resource_group_name = "rg-az104-user-01"

# 필수: 강사가 알려준 공유 ACR 이름
acr_name = "az104acrktds20260508"

# 선택
# subscription_id         = ""
# tenant_id               = ""
# prefix                  = "az104-lab09a"
# location                = ""                      # 비우면 RG location 사용
# acr_resource_group_name = "rg-az104-shared"       # 기본값 사용 가능
# container_image         = "awesome-apigateway:latest"
# sku_name                = "B1"
