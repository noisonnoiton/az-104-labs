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
  default     = "az104-lab08"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.prefix)) && length(var.prefix) <= 20
    error_message = "prefix: 소문자, 숫자, 하이픈만 허용. 20자 이하."
  }
}

variable "location" {
  type        = string
  description = "선택. 비우면 할당된 RG 의 location 사용."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "리소스에 붙일 공통 태그."
  default     = {}
}

# --- Network ---

variable "vnet_address_space" {
  type        = string
  description = "VNet CIDR."
  default     = "10.40.0.0/16"
}

variable "subnet_prefix" {
  type        = string
  description = "Workload subnet CIDR."
  default     = "10.40.0.0/24"
}

# --- VM ---

variable "admin_username" {
  type        = string
  description = "Ubuntu VM admin username."
  default     = "azureuser"
}

variable "vm_size" {
  type        = string
  description = "VM size. 기본 Standard_D2s_v3 (burstable)."
  default     = "Standard_D2s_v3"
}

variable "availability_zone" {
  type        = string
  description = "VM 배치 가용성 영역 (1, 2, 3). region이 zone 미지원이면 빈 문자열."
  default     = "1"
}

variable "data_disk_size_gb" {
  type        = number
  description = "추가 데이터 디스크 크기 (GiB)."
  default     = 32
}
