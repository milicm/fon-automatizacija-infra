# fon-automatizacija Terraform Infrastructure

This repository contains Terraform code to provision AWS infrastructure for the `fon-automatizacija` project.
It sets up an ECS Fargate cluster, ECR repository, IAM roles, VPC, security groups, and CloudWatch logging.

## Project Structure

- `main.tf` – Terraform backend and provider configuration
- `variables.tf` – Input variables (e.g., AWS account ID)
- `terraform.tfvars` – Variable values (e.g., your AWS account ID)
- `vpc.tf` – VPC and networking resources
- `ecs.tf` – ECS cluster, service, task definition, ECR, and logging
- `iam.tf` – IAM roles and policies
- `.github/workflows/` – GitHub Actions CI/CD workflows

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 5.83.0, < 6.0.0
- AWS account and credentials with permissions to manage resources
- [AWS CLI](https://aws.amazon.com/cli/) (for local usage)
- [GitHub Actions secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) for CI/CD

### AWS CLI Authentication (Local Usage)

To use Terraform locally, the AWS CLI must be authenticated. The easiest way is to configure them interactively:

```sh
aws configure
```

### S3 Backend for Terraform State
The Terraform backend is configured to store the state remotely in an S3 bucket:
```hcl
backend "s3" {
  bucket         = "terraform-state-bucket-1cf48a7e-0cce-4afc-b29e-8584937eb9e9"
  key            = "fon-automatizacija/terraform.tfstate"
  region         = "eu-central-1"
  use_lockfile   = true
  encrypt        = true
}
```

If the bucket does not exist, create it before running terraform init:
```sh
aws s3api create-bucket \
  --bucket terraform-state-bucket-1cf48a7e-0cce-4afc-b29e-8584937eb9e9 \
  --region eu-central-1 \
  --create-bucket-configuration LocationConstraint=eu-central-1
```

Note: If you do not want to use remote state storage, remove or comment out the backend "s3" block from your main.tf file to store the Terraform state file locally.

## Usage

### 1. Clone the repository

```sh
git clone https://github.com/UrosVesic/fon-automatizacija-infra.git
cd fon-automatizacija-infra
```

### 2. Configure Variables
Edit `terraform.tfvars` and set your AWS account ID and any other required variables.

### 3. Initialize Terraform
```sh
terraform init
```

### 4. Plan the Infrastructure
```sh
terraform plan
```

### 5. Apply the Infrastructure
```sh
terraform apply
```

### 6. Destroy the Infrastructure
```sh
terraform destroy
```

## CI/CD Pipeline

GitHub Actions workflows are provided in `.github/workflows/`:

### `terraform-plan-apply.yml`

- Runs on pull requests and pushes to `main`.
- On pull request: runs `terraform plan`.
- On push to `main`: runs `terraform plan` and `terraform apply`.

### `terraform-destroy.yml`

- Manual trigger (`workflow_dispatch`).
- Runs `terraform destroy`.

### Required GitHub Secrets

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

Set these in your repository settings under: Settings > Secrets and variables > Actions



