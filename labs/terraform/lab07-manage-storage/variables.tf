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
  default     = "az104-lab07"

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

# --- Storage ---

variable "account_tier" {
  type        = string
  description = "Storage Account tier."
  default     = "Standard"
}

variable "account_replication_type" {
  type        = string
  description = "복제 유형: LRS, GRS, ZRS, RAGRS 등."
  default     = "LRS"
}

variable "file_share_name" {
  type        = string
  description = "Azure Files share 이름."
  default     = "share01"
}

variable "file_share_quota" {
  type        = number
  description = "File share quota (GiB)."
  default     = 5
}

# --- Network ---

variable "vnet_address_space" {
  type        = string
  description = "VNet CIDR."
  default     = "10.30.0.0/16"
}

variable "subnet_prefix" {
  type        = string
  description = "VM subnet CIDR."
  default     = "10.30.0.0/24"
}

variable "network_default_action" {
  type        = string
  description = "Storage network rules default action: Allow or Deny."
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.network_default_action)
    error_message = "network_default_action must be 'Allow' or 'Deny'."
  }
}

# --- VM ---

variable "vm_size" {
  type        = string
  description = "VM SKU."
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  type        = string
  description = "VM admin username."
  default     = "azureuser"
}
