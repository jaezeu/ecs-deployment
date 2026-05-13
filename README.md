# ECS Deployment POC

A proof-of-concept demonstrating GitHub Actions CI/CD to deploy a containerised Python/Flask app to AWS ECR and ECS Fargate, with infrastructure managed by Terraform.

# Architecture Diagram

![githubactionecr drawio](https://user-images.githubusercontent.com/48310743/232531154-c0dd01d5-8666-4619-af29-aa2d7c2a7e7b.png)

# Project Structure

```
.
├── app.py                  # Flask app serving on port 8080
├── requirements.txt        # Python dependencies (Flask)
├── Dockerfile              # Container definition using python:latest
└── terraform/
    ├── backend.tf          # S3 remote state backend (ap-southeast-1)
    ├── main.tf             # ECR repo, ECS Fargate cluster, service, and security group
    └── provider.tf         # AWS provider (ap-southeast-1)
```

# Application

A simple Python/Flask HTTP server:

| Endpoint | Response |
|----------|----------|
| `GET /` | `Hello, YOURNAME!` |

Listens on `0.0.0.0:8080`.

## Run Locally

```bash
pip install -r requirements.txt
python app.py
# App available at http://localhost:8080
```

## Run with Docker

```bash
docker build -t flask-app .
docker run -p 8080:8080 flask-app
```

# Infrastructure (Terraform)

Provisions the following AWS resources in **ap-southeast-1**:

- **ECR Repository** — stores the Docker image (`<prefix>-ecs-demo-ecr`)
- **ECS Fargate Cluster** — runs the containerised app (`<prefix>-ecs-demo`)
  - Task: 512 CPU / 1024 MB memory
  - Container port: `8080/tcp`
  - Assigns a public IP; uses the default VPC and its subnets
- **Security Group** — allows inbound `HTTP:8080` from `0.0.0.0/0`, all egress

Remote state is stored in S3 (`sctp-core-tfstate` bucket, `ecs-cicd-jaz.tfstate` key).

The resource name prefix is derived automatically from the IAM caller identity (the IAM username segment of the ARN).

## Terraform Usage

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

# CI/CD

Four GitHub Actions workflows are included:

| Workflow | Trigger | Description |
|----------|---------|-------------|
| `Deploy Infrastructure` | `workflow_dispatch` | Runs `terraform init → plan → apply` to provision AWS resources |
| `Destroy Infrastructure` | `workflow_dispatch` | Runs `terraform destroy` to tear down all resources |
| `Deploy to Amazon ECS` | `workflow_dispatch` | Builds image with Docker Buildx, pushes to ECR, updates ECS task definition, deploys to Fargate |
| `docker-build-multienv` | *(commented out)* | Multi-branch variant (dev/uat/main) for future multi-environment deployments |

## Required GitHub Secrets & Variables

| Name | Type | Description |
|------|------|-------------|
| `AWS_ACCESS_KEY_ID` | Secret | IAM access key |
| `AWS_SECRET_ACCESS_KEY` | Secret | IAM secret key |
| `AWS_REGION` | Variable | Target AWS region (e.g. `ap-southeast-1`) |
| `ECR_REPOSITORY` | Variable | ECR repository name |
| `TASK_DEF` | Variable | ECS task definition family name |
| `CONTAINER_NAME` | Variable | Container name within the task definition |
| `ECS_SERVICE` | Variable | ECS service name |
| `ECS_CLUSTER` | Variable | ECS cluster name |
