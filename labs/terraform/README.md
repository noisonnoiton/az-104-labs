# AZ-104 Lab — Terraform

!!! abstract "이 디렉터리의 역할"
    Terraform 기반 **커스텀 Lab**과 **온보딩 검증 skeleton**을 모아 둔 폴더입니다. 각 하위 디렉터리가 독립된 **root module**입니다. 필요한 것만 골라서 `terraform init` 하세요.

## 구성

| 디렉터리 | 목적 | 실행 주체 |
| --- | --- | --- |
| [`00-skeleton/`](./00-skeleton/) | 할당된 **Resource Group** 연결·권한 검증 (`data` only) | 수강생 (**온보딩 첫 적용**) |
| [`lab04-virtual-networking/`](./lab04-virtual-networking/) | Lab 04 대응: VNet·Subnet·NSG·ASG·Private DNS·Peering·Bastion·Ubuntu VM | 수강생 (1일차 오후) |
| `instructor-bootstrap/` | **강사 전용**: 수강생별 RG 일괄 생성 | 강사 (구독 권한 필요) |

!!! note "강사 전용 디렉터리"
    `instructor-bootstrap/`는 **구독 수준 권한**이 필요하므로 수강생 사이트(MkDocs)에는 노출하지 않습니다. **public 미러 저장소(`az-104-labs` 등)**에도 넣지 않는 것을 권장합니다.

!!! tip "수강생 clone 출처"
    공개 과정이면 **`az-104-labs`** 한 저장소에 문서 소스와 이 `labs/terraform/` 트리를 같이 두고 clone 하게 할 수 있습니다. 강사 내부 저장소와 동기화·제외 경로는 과정 소스 저장소의 `docs/AZ-104-LABS-PUBLIC-REPO.md`를 참고합니다.

## 사용 순서 (수강생)

1. **`00-skeleton/`** — `terraform init` / `plan` / `apply`로 본인 RG 연결만 검증  
2. **`lab04-virtual-networking/`** — Lab 04 시나리오 배포 (소요·비용 주의)  

각 폴더의 `README.md`에 **사전 조건 · apply · 검증 · destroy** 순서가 적혀 있습니다.

!!! warning "state 파일"
    각 하위 모듈은 **독립된 state**(`terraform.tfstate`)를 갖습니다. 한 폴더에서 `init`한 뒤 다른 폴더로 이동해 쓰면 안 됩니다.
