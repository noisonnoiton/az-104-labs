# Lab AKS — ACR + AKS Deployment

AKS 클러스터를 배포하고, 강사가 사전 생성한 **공유 ACR**에 연결(AcrPull)합니다.

## Resources

| Resource | Name / Description |
| --- | --- |
| VNet | `vnet-{prefix}` (10.50.0.0/16) |
| Subnet | `snet-aks` (10.50.0.0/22) |
| AKS Cluster | `aks-{prefix}` — Azure CNI Overlay, system + user node pool |
| Role Assignment | AcrPull — AKS kubelet → shared ACR |

## Prerequisites

- Terraform **1.6+**, Azure CLI
- `az login` 후 올바른 subscription 선택
- 강사가 알려준 **공유 ACR 이름** (`acr_name`)

## Quick Start

```bash
cd labs/terraform/lab90-aks
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 편집: resource_group_name, acr_name 설정

terraform init
terraform plan
terraform apply
```

## kubeconfig

```bash
az aks get-credentials -g <RG> -n aks-az104-aks --overwrite-existing
kubectl get nodes
```

## Teardown

```bash
terraform destroy
```

> **Warning**: AKS 클러스터는 시간당 과금됩니다. 실습 후 반드시 `terraform destroy`를 실행하세요.
