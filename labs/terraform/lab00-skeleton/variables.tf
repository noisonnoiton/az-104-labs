variable "subscription_id" {
  type        = string
  description = "선택. 비우면 'az account show' 의 구독이 사용됩니다."
  default     = ""
}

variable "tenant_id" {
  type        = string
  description = "선택. 대부분 비워 두고 az CLI 세션을 사용합니다."
  default     = ""
}

variable "resource_group_name" {
  type        = string
  description = "강사가 할당한 본인 Resource Group 이름 (필수)."
}
