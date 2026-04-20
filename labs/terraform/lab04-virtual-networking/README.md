# Lab 04 — Virtual Networking (Terraform)

!!! abstract "목표"
    공식 [Lab 04 — Implement Virtual Networking](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/Instructions/Labs/LAB_04-Implement_Virtual_Networking.html)에서 다루는 **VNet·Subnet·NSG·ASG·Peering·Private DNS·Bastion** 개념을 **Terraform**으로 한 번에 배포하고, **Portal·CLI**로 검증합니다. 공식 Lab은 **Windows Server** VM이 많지만, 본 구성은 **Ubuntu 24.04**로 동일한 네트워크 패턴을 연습합니다.

## 이 모듈에서 만드는 것

| 리소스 | 기본 이름/값 |
| --- | --- |
| Hub VNet / Spoke VNet | `vnet-{prefix}-hub` / `vnet-{prefix}-spoke` (`10.10.0.0/16`, `10.20.0.0/16`) |
| Workload subnet | Hub·Spoke 각 `snet-workload` (`/24`), 동일 NSG 연결 |
| `AzureBastionSubnet` | `10.10.100.0/26` (Bastion 전용 이름 고정) |
| Peering | `peer-hub-to-spoke`, `peer-spoke-to-hub` (양방향) |
| NSG | `nsg-{prefix}-workload` — SSH from Bastion subnet, ICMP between VNets, HTTP to ASG |
| ASG | `asg-{prefix}-app` — 두 VM NIC에 연결 |
| Private DNS | zone `lab04.internal`(변경 가능), VNet link×2, `vm-hub`·`vm-spoke` A record |
| Bastion | Basic SKU + Standard Public IP |
| VM | `vm-hub`, `vm-spoke` — Ubuntu 24.04, password auth (`random_password`) |

!!! warning "비용"
    **Azure Bastion (Basic)** 과 **VM 2대**가 **시간당 과금**됩니다. 실습 후 **`terraform destroy`** 로 정리하세요.

---

## 선행 조건

| 항목 | 내용 |
| --- | --- |
| 권한 | 할당 **Resource Group**에 **Contributor** 이상 (해당 RG 안에 리소스 생성) |
| 도구 | [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli), Terraform **1.6+** |
| 인증 | [`az login`](../../lab-onboarding/01-azure-access-terraform-auth.md) 후 올바른 **subscription** 선택 |
| 순서 권장 | 먼저 [`../00-skeleton/`](../00-skeleton/)으로 RG 연결을 검증한 뒤 이 폴더에서 진행 |

---

## 공식 Lab 04와의 대응 (개념)

공식 Lab의 **Exercise 번호·UI 순서**와 1:1은 아니지만, 아래 개념이 이 Terraform에 포함됩니다.

| 공식 Lab 04 주제 (요약) | 이 모듈에서의 위치 |
| --- | --- |
| VNet·Subnet 설계 | `network.tf` — Hub/Spoke, workload·Bastion subnet |
| NSG 규칙 | `security.tf` — 우선순위 100/110/120 규칙 |
| ASG | `security.tf` — `azurerm_application_security_group`, NIC association |
| VNet Peering | `network.tf` — 양방향 peering |
| Private DNS | `dns.tf` — zone, VNet link, A record |
| Bastion | `bastion.tf` — Basic SKU (Portal SSH) |
| VM 연결 검증 | `vm.tf` — Ubuntu 24.04, 내부 IP·DNS 이름으로 접속 테스트 |

---

## 실행 순서

### 1) 변수 파일

```bash
cd labs/terraform/lab04-virtual-networking   # 저장소 기준 경로
cp terraform.tfvars.example terraform.tfvars
```

`terraform.tfvars`에서 최소한 다음을 맞춥니다.

- **`resource_group_name`** — 강사가 알려준 **본인 RG** 이름 (다른 사람 RG 금지)

`subscription_id`는 비워 두면 현재 `az` context의 subscription이 사용됩니다.

### 2) 로그인·subscription 확인

```bash
az login
az account show -o table
# 필요 시
az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
```

### 3) Terraform

```bash
terraform init
terraform plan
terraform apply
```

!!! tip "`terraform plan`에서 볼 것"
    - **추가될 리소스 수** — VNet, subnet, NSG rule, VM 등이 기대와 같게 나오는지
    - **`random_password`** — VM 비밀번호가 새로 생성되는지 (재적용 시 변경될 수 있음)

`apply` 완료까지 **수 분~십여 분** 걸릴 수 있습니다(Bastion·VM 프로비저닝).

### 4) 출력 확인

```bash
terraform output
terraform output admin_username
terraform output -raw admin_password
```

비밀번호는 **터미널 기록·스크린샷에 남기지 마세요.**

---

## 검증 — Azure Portal

1. **Resource Group** → 배포된 RG → 리소스 목록에 VNet×2, VM×2, Bastion, Private DNS zone 등이 보이는지 확인합니다.
2. **Bastion** 리소스(`bas-{prefix}`) → **Connect** → **SSH** → 대상 VM **`vm-hub`**, 사용자명·비밀번호는 `terraform output` 값.
3. **Basic Bastion**은 **peered Spoke VM에 직접 연결할 수 없습니다.** Spoke 검증은 아래 **허브 VM에서 SSH**로 진행합니다.

### Hub에서 Spoke로 (Peering + Private DNS)

`vm-hub`에 Bastion으로 접속한 뒤:

```bash
# Private DNS 이름으로 Spoke VM 접속 (같은 zone: lab04.internal 기본)
ssh <admin_username>@vm-spoke.lab04.internal
# 호스트 키 확인 메시지 → yes
# 비밀번호는 Hub와 동일 (random_password 공유)
```

접속되면 **VNet peering**과 **Private DNS**가 함께 동작하는 것입니다.

### 네트워크 동작 확인 (선택)

Hub 세션에서:

```bash
ping -c 3 <spoke_vm_private_ip>    # ICMP 허용 규칙 검증
curl -sS -o /dev/null -w "%{http_code}\n" http://<spoke_vm_private_ip>/
# 80번 포트는 NSG에서 ASG 대상으로 열려 있으나, VM에 웹 서버가 없으면 연결 거부/실패할 수 있음 (규칙 존재 vs 서비스 유무 구분)
```

---

## 검증 — Azure CLI

`RESOURCE_GROUP`과 `LOCATION`은 `terraform output` 또는 `terraform.tfvars`와 맞춥니다.

```bash
RG="<YOUR_RESOURCE_GROUP>"
```

### Peering

```bash
az network vnet-peering list -g "$RG" --vnet-name "$(terraform output -raw vnet_hub_name)" -o table
az network vnet-peering list -g "$RG" --vnet-name "$(terraform output -raw vnet_spoke_name)" -o table
```

양쪽에 **Connected** 상태의 peering이 있어야 합니다.

### Private DNS zone

```bash
ZONE="$(terraform output -raw private_dns_zone)"
az network private-dns zone show -g "$RG" -n "$ZONE" -o table
az network private-dns link vnet list -g "$RG" --zone-name "$ZONE" -o table
az network private-dns record-set a list -g "$RG" --zone-name "$ZONE" -o table
```

### VM (개요)

```bash
az vm list -g "$RG" -d -o table
```

---

## 트러블슈팅

| 증상 | 점검 |
| --- | --- |
| `403` / `Authorization failed` | `resource_group_name`이 **본인 RG**인지, **subscription**이 맞는지, **Contributor**가 해당 RG에 있는지 확인합니다. |
| `plan`에서 이미지 오류 | `vm.tf`의 Ubuntu **publisher/offer/sku**가 해당 region에서 지원되는지 [공식 이미지 목록](https://learn.microsoft.com/azure/virtual-machines/linux/cli-ps-json#list-popular-images)으로 확인합니다. |
| Bastion **Provisioning**이 오래 걸림 | 10~20분 이상 지연될 수 있습니다. Portal에서 Bastion 상태가 **Succeeded**인지 확인 후 VM 연결을 시도합니다. |
| Bastion으로 **vm-spoke**만 안 됨 | **의도된 제약**입니다. Basic Bastion은 peered VNet의 VM에 연결하지 못할 수 있습니다. **vm-hub**로 들어가 **SSH**로 Spoke를 검증합니다. |
| `ssh vm-spoke...` 이름 실패 | Private DNS zone 이름·A record(`dns.tf`)와 `terraform output private_dns_zone`이 일치하는지, Spoke VM이 같은 zone에 등록됐는지 확인합니다. |
| 비밀번호를 잊음 | `terraform output -raw admin_password`로 다시 확인합니다. state를 잃었다면 `terraform apply -replace=random_password.vm` 등으로 재생성(서비스 영향 있음). |

---

## 정리 (`destroy`)

```bash
terraform destroy
```

!!! danger "주의"
    해당 RG 안의 **이 모듈이 만든 리소스가 모두 삭제**됩니다. 같은 RG에 다른 실습 리소스가 있으면 **함께 지워지지는 않지만**, 이름 충돌·의존성 문제가 없는지 확인하세요.

destroy 후에도 **Public IP**나 **Bastion**이 남아 보이면 Portal에서 RG를 새로고침하거나, 몇 분 후 다시 확인합니다.

---

## 파일 구조

| 파일 | 역할 |
| --- | --- |
| `versions.tf` / `providers.tf` | Terraform / `azurerm` / `random` |
| `variables.tf` | 입력·validation |
| `main.tf` | RG `data`, `random_password` |
| `network.tf` | VNet, subnet, peering |
| `security.tf` | NSG, ASG, subnet 연결 |
| `dns.tf` | Private DNS zone, link, A record |
| `bastion.tf` | Public IP, Bastion |
| `vm.tf` | NIC, Ubuntu 24.04 VM |
| `outputs.tf` | RG, VNet, Bastion, DNS, VM IP, 계정 |

---

## 관련 문서

- [Terraform Lab 인덱스](../README.md)
- [00 · skeleton (RG 검증)](../00-skeleton/README.md)
- [Azure 접근 및 Terraform 인증](../../lab-onboarding/01-azure-access-terraform-auth.md)
