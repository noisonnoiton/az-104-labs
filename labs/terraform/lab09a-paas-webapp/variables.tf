variable "subscription_id" {
  type        = string
  description = "선택. 비우면 az CLI 의 현재 subscription 사용."
  default     = ""
}

variable "tenant_id" {
  type        = string
  description = "선택. 보통 비워 두고 az CLI session 을 사용."
  default     = ""
}

variable "resource_group_name" {
  type        = string
  description = "강사가 할당한 본인 Resource Group 이름 (필수)."

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "resource_group_name 은 반드시 지정해야 합니다."
  }
}

variable "prefix" {
  type        = string
  description = "리소스 이름 prefix."
  default     = "az104-lab09a"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.prefix)) && length(var.prefix) <= 20
    error_message = "prefix: 소문자, 숫자, 하이픈만 허용. 20자 이하."
  }
}

variable "location" {
  type        = string
  description = "배포 region. 비우면 RG 의 location 사용."
  default     = ""
}

# ---------- ACR (공유) ----------
variable "acr_name" {
  type        = string
  description = "강사가 생성한 공유 ACR 이름 (필수). Web App이 이미지를 pull."
}

variable "acr_resource_group_name" {
  type        = string
  description = "공유 ACR이 있는 Resource Group 이름."
  default     = "rg-az104-shared"
}

# ---------- Container Image ----------
variable "container_image" {
  type        = string
  description = "배포할 컨테이너 이미지 (repository:tag). ACR login server는 자동 조합."
  default     = "awesome-apigateway:latest"
}

# ---------- App Service Plan ----------
variable "sku_name" {
  type        = string
  description = "App Service Plan SKU (B1, B2, S1, P1v3 등)."
  default     = "B1"
}
