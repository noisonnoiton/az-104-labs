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
  description = "강사가 할당한 본인 Resource Group 이름 (필수). 이 RG 안에 Lab 04 리소스가 생성됩니다."

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "resource_group_name 은 반드시 지정해야 합니다."
  }
}

variable "prefix" {
  type        = string
  description = "리소스 이름 prefix. 기본 \"az104-lab04\"."
  default     = "az104-lab04"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.prefix)) && length(var.prefix) <= 20
    error_message = "prefix 는 소문자·숫자·하이픈만 허용하며 20자 이하여야 합니다."
  }
}

variable "location" {
  type        = string
  description = "선택. 비우면 할당된 RG 의 location 사용."
  default     = ""
}

variable "admin_username" {
  type        = string
  description = "Ubuntu VM admin username."
  default     = "azureuser"
}

variable "hub_address_space" {
  type        = string
  description = "Hub VNet CIDR."
  default     = "10.10.0.0/16"
}

variable "spoke_address_space" {
  type        = string
  description = "Spoke VNet CIDR."
  default     = "10.20.0.0/16"
}

variable "hub_workload_subnet" {
  type        = string
  description = "Hub workload subnet CIDR."
  default     = "10.10.1.0/24"
}

variable "hub_bastion_subnet" {
  type        = string
  description = "AzureBastionSubnet CIDR (최소 /26)."
  default     = "10.10.100.0/26"
}

variable "spoke_workload_subnet" {
  type        = string
  description = "Spoke workload subnet CIDR."
  default     = "10.20.1.0/24"
}

variable "vm_size" {
  type        = string
  description = "Ubuntu VM size. 기본 Standard_B2s (burstable, gen2)."
  default     = "Standard_B2s"
}

variable "private_dns_zone_name" {
  type        = string
  description = "Private DNS zone 이름."
  default     = "lab04.internal"
}

variable "tags" {
  type        = map(string)
  description = "공통 tag."
  default = {
    course  = "AZ-104"
    lab     = "04"
    managed = "terraform"
  }
}
