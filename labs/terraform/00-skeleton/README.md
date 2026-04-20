# 00 · Terraform Skeleton — RG 연결 검증

!!! abstract "이 skeleton에서 하는 일"
    할당된 **Resource Group**에 연결 가능한지·권한이 있는지 검증합니다. 본격 Lab 전에 **가장 먼저 한 번** 돌리고 넘어가는 최소 구성입니다.

!!! tip "다음 단계"
    검증이 끝나면 [`../lab04-virtual-networking/`](../lab04-virtual-networking/)로 이동해 Lab 04를 진행합니다.

## 전제

- 강사가 **subscription** 안에 수강생별 **Resource Group**을 만들고, 수강생 계정에 해당 RG에 대해 **Contributor** (또는 동급) 권한을 부여합니다.
- 수강생은 **subscription Owner**가 아닐 수 있습니다. Terraform은 **할당된 RG 안**에 리소스를 만들거나, 이미 존재하는 RG에 연결합니다.

!!! warning "반드시 확인"
    `terraform.tfvars`의 **`resource_group_name`**은 강사가 알려준 **본인 RG 이름**과 일치해야 합니다. 다른 사람 RG·다른 **subscription**에 적용하지 않도록 주의하세요.

## 사전 준비

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) 설치
- [Terraform](https://developer.hashicorp.com/terraform/install) 1.6+ 설치
- 문서: [Azure 접근 및 Terraform 인증](../../lab-onboarding/01-azure-access-terraform-auth.md), [Windows](../../lab-onboarding/02-setup-windows.md), [macOS](../../lab-onboarding/03-setup-macos.md)

## 빠른 시작

1. `terraform.tfvars`를 만듭니다 (예시는 `terraform.tfvars.example` 참고).

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # terraform.tfvars를 열어 resource_group_name 등 수정
   ```

2. Azure에 로그인하고, **과정에서 안내한 subscription**이 선택되어 있는지 확인합니다.

   ```bash
   az login
   az account show -o table
   az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"   # 필요 시
   ```

3. 초기화 및 계획:

   ```bash
   terraform init
   terraform plan
   ```

4. **skeleton** 단계에서는 **기존 Resource Group**을 `data`로 읽고 출력만 합니다. `apply`로 RG 존재·권한을 검증합니다.

   ```bash
   terraform apply
   ```

5. 실습 종료 후 리소스 정리는 강사 안내에 따릅니다. 이 **skeleton**만 적용한 경우:

   ```bash
   terraform destroy
   ```

!!! note "skeleton 단계"
    이 폴더는 **RG 연결·권한 검증**이 목적입니다. 실제 리소스 배포는 [`../lab04-virtual-networking/`](../lab04-virtual-networking/) 등 별도 root module 에서 진행합니다.

## 파일

| 파일 | 역할 |
| --- | --- |
| `versions.tf` | Terraform / provider 버전 |
| `providers.tf` | `azurerm` provider |
| `variables.tf` | RG 이름, 지역, 태그 등 |
| `main.tf` | RG data source 및 출력 (연결 검증) |
| `terraform.tfvars.example` | sample **variables** (비밀 없음) |

## 비용·주의

!!! danger "실수 방지"
    잘못된 **subscription**/RG에 적용하지 않도록 `terraform.tfvars`의 `resource_group_name`을 **반드시 본인 RG**로 맞춥니다.
