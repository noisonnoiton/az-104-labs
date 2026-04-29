# ---------- 공통 ----------
variable "prefix" {
  type        = string
  description = "리소스 이름 prefix."
  default     = "az104-aks"
}

variable "resource_group_name" {
  type        = string
  description = "본인에게 할당된 Resource Group 이름 (필수)."
}

variable "subscription_id" {
  type        = string
  description = "선택. 비우면 az CLI 현재 구독 사용."
  default     = ""
}

variable "tenant_id" {
  type        = string
  description = "선택. 비우면 az CLI 세션의 tenant 사용."
  default     = ""
}

variable "location" {
  type        = string
  description = "선택. 비우면 RG location 사용."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "공통 tag."
  default = {
    course  = "AZ-104"
    lab     = "aks"
    managed = "terraform"
  }
}

# ---------- 네트워크 ----------
variable "vnet_address_space" {
  type        = string
  description = "VNet CIDR."
  default     = "10.50.0.0/16"
}

variable "aks_subnet_cidr" {
  type        = string
  description = "AKS 노드 서브넷 CIDR."
  default     = "10.50.0.0/22"
}

# ---------- AKS ----------
variable "kubernetes_version" {
  type        = string
  description = "AKS Kubernetes 버전. 비우면 최신 stable."
  default     = null
}

variable "system_node_count" {
  type        = number
  description = "System node pool 노드 수."
  default     = 1
}

variable "user_node_count" {
  type        = number
  description = "User node pool 노드 수."
  default     = 1
}

variable "vm_size" {
  type        = string
  description = "AKS 노드 VM 크기."
  default     = "Standard_D2s_v3"
}

# ---------- ACR (공유) ----------
variable "acr_name" {
  type        = string
  description = "강사가 생성한 공유 ACR 이름 (필수). AKS kubelet에 AcrPull 권한 부여."
}

variable "acr_resource_group_name" {
  type        = string
  description = "공유 ACR이 있는 Resource Group 이름."
  default     = "rg-az104-shared"
}
