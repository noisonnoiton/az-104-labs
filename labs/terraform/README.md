# AZ-104 Lab — Terraform

This directory contains Terraform-based custom labs and an onboarding verification skeleton. Each subdirectory is an independent Terraform root module; run `terraform init` only in the module you intend to use.

## Structure

| Directory | Purpose | Intended user |
| --- | --- | --- |
| [`lab00-skeleton/`](../lab00-skeleton/index.md) | Verify connection to assigned Resource Group (data only) | Students (onboarding)
| [`lab04-virtual-networking/`](../lab04-virtual-networking/index.md) | Lab 04: VNet, Subnet, NSG, ASG, Private DNS, Peering, Bastion, Ubuntu VM | Students (Day 1 afternoon)
| [`lab07-manage-storage/`](../lab07-manage-storage/index.md) | Lab 07: Storage Account, Blob, Azure Files, Service Endpoint | Students (Day 1)
| [`lab08-manage-vms/`](../lab08-manage-vms/index.md) | Lab 08: Linux VM, Data Disk, Custom Script Extension, Public IP | Students (Day 2)
| [`lab90-aks/`](../lab90-aks/index.md) | Lab AKS: AKS Cluster (system + user pool), ACR attach, kubectl | Students (Day 2)
| `99-instructor-bootstrap/` | Instructor-only: bulk-create per-student Resource Groups, shared ACR | Instructor (requires subscription permissions)

> Note: `99-instructor-bootstrap/` requires subscription-level permissions and should not be exposed in the student-facing MkDocs site or included in public mirrors (e.g., `az-104-labs`).

> Tip: For public offerings you can maintain a public `az-104-labs` repository that contains the documentation and a trimmed `labs/terraform/` tree for students to clone. See `docs/AZ-104-LABS-PUBLIC-REPO.md` for sync/exclude guidance.

## Usage (students)

1. **`lab00-skeleton/`** — Run `terraform init`, `plan`, `apply` to verify your assigned RG connection.
2. **`lab04-virtual-networking/`** — Deploy the Lab 04 scenario (VNet, Peering, Bastion, VMs).
3. **`lab07-manage-storage/`** — Deploy Storage Account with Blob, Azure Files, and service endpoint.
4. **`lab08-manage-vms/`** — Deploy a Linux VM with data disk and Custom Script Extension.
5. **`lab90-aks/`** — Deploy AKS cluster with ACR attachment. Requires shared ACR name from instructor.

Each module contains a `README.md` describing prerequisites, apply/verify/destroy steps.

**Warning (state files):** Each submodule uses an independent Terraform state (`terraform.tfstate`). Do not reuse state across folders — initialize and operate in the module directory you intend to manage.
