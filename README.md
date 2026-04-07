# Introduction

This is a sample application used to demonstrate a POC of using GitHub Actions to deploy to AWS ECR and Fargate.

# Architecture Diagram

![githubactionecr drawio](https://user-images.githubusercontent.com/48310743/232531154-c0dd01d5-8666-4619-af29-aa2d7c2a7e7b.png)

# Project Structure

```
.
├── Dockerfile          # Container definition using node:16-alpine
├── index.js            # Express app serving on port 8080
├── package.json        # Node.js dependencies (Express 4.x)
└── terraform/
    ├── backend.tf      # S3 remote state backend (ap-southeast-1)
    ├── main.tf         # ECR repo, ECS Fargate cluster, service, and security 
    └── provider.tf     # AWS provider (ap-southeast-1)
```

# Application

A simple Node.js/Express HTTP server with two endpoints:

| Endpoint | Response |
|----------|----------|
| `GET /` | `Hello from Node 4!` |
| `GET /test` | `Hello from /test Node!` |

Listens on `0.0.0.0:8080`.

## Run Locally

```bash
npm install
npm start
# App available at http://localhost:8080
```

## Run with Docker

```bash
docker build -t hello-node .
docker run -p 8080:8080 hello-node
```

# Infrastructure (Terraform)

Provisions the following AWS resources in **ap-southeast-1**:

- **ECR Repository** — stores the Docker image (`<prefix>-ecr`)
- **ECS Fargate Cluster** — runs the containerised app (`<prefix>-ecs`)
  - Task: 512 CPU / 1024 MB memory
  - Container port: `8080/tcp`
  - Assigns a public IP; uses the default VPC and its subnets
- **Security Group** — allows inbound `HTTP:8080` from `0.0.0.0/0`, all egress
- **S3 Backend** — remote state stored in `sctp-core-tfstate` (`ecs-cicd-jaz.tfstate`)

## Terraform Usage

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

> Update the `prefix` local in `main.tf` before deploying to avoid naming collisions.

# CI/CD

GitHub Actions workflow builds the Docker image, pushes it to ECR, and triggers a new ECS deployment on every push.
