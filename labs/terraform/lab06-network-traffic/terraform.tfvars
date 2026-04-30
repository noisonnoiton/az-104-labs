#==============================================================================
# Lab 04 — Virtual Networking (Terraform)
# 복사: cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 는 민감 정보가 담길 수 있어 공개 저장소에 커밋하지 마세요.
#==============================================================================

# 필수: 강사가 알려준 본인 RG 이름
resource_group_name = "rg-az104-user-01"
subscription_id = "9fe30ad6-656c-44f3-828e-c1092f72ffda"

# 선택
# subscription_id       = ""          # 비우면 az CLI 현재 구독
# tenant_id             = ""
# prefix                = "az104-lab04"
# location              = ""          # 비우면 RG location 사용
# admin_username        = "azureuser"
# vm_size               = "Standard_B2s"
# private_dns_zone_name = "lab04.internal"

# CIDR (기본값 그대로 써도 됨)
# hub_address_space     = "10.10.0.0/16"
# spoke_address_space   = "10.20.0.0/16"
# hub_workload_subnet   = "10.10.1.0/24"
# hub_bastion_subnet    = "10.10.100.0/26"
# spoke_workload_subnet = "10.20.1.0/24"
