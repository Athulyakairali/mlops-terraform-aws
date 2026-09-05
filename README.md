# 🚀 MLOps API on AWS with Terraform & Docker

A production-style DevOps/MLOps project that provisions an AWS EC2 instance using Terraform, deploys a containerized FastAPI application with Docker, and implements automated health monitoring and self-healing.

## 🏗️ Architecture

```text
                    ┌──────────────────────┐
                    │      Developer       │
                    │      Mac / VS Code   │
                    └──────────┬───────────┘
                               │
                               │ Terraform
                               ▼
                    ┌──────────────────────┐
                    │        AWS           │
                    │     eu-central-1     │
                    │                      │
                    │  ┌────────────────┐  │
                    │  │   EC2 Ubuntu   │  │
                    │  │                │  │
                    │  │    Docker      │  │
                    │  │  ┌──────────┐  │  │
                    │  │  │ FastAPI  │  │  │
                    │  │  │  :8000   │  │  │
                    │  │  └──────────┘  │  │
                    │  │       ▲        │  │
                    │  │       │        │  │
                    │  │  Healthcheck   │  │
                    │  │       ▲        │  │
                    │  │       │        │  │
                    │  │  Cron every 5m │  │
                    │  └────────────────┘  │
                    └──────────┬───────────┘
                               │
                               ▼
                         Public API
                       Port 8000 / HTTP
```

## 🛠️ Tech Stack

- **AWS EC2** — Application hosting
- **Terraform** — Infrastructure as Code
- **Docker** — Application containerization
- **FastAPI** — REST API
- **Uvicorn** — ASGI server
- **Ubuntu 24.04** — EC2 operating system
- **Bash** — Health monitoring script
- **Cron** — Scheduled health monitoring
- **Git/GitHub** — Version control

## ✨ Features

### Infrastructure as Code

Terraform provisions:

- AWS EC2 instance
- Ubuntu 24.04 AMI
- SSH key pair
- Security group
- Docker installation
- Application deployment

### Containerized FastAPI Application

The API runs inside a Docker container named:

```text
mlops-api
```

The container exposes port `8000`.

### API Endpoints

#### `GET /`

Returns:

```json
{
  "message": "MLOps API is running!",
  "status": "healthy"
}
```

#### `GET /health`

Returns:

```json
{
  "status": "healthy"
}
```

The `/health` endpoint is also used by Docker's container healthcheck.

## ❤️ Health Monitoring & Self-Healing

The Docker container has a built-in healthcheck that runs every 30 seconds.

```text
             Docker Container
                    │
                    ▼
              GET /health
                    │
              ┌─────┴─────┐
              │           │
           healthy     unhealthy
              │           │
              ▼           ▼
          Continue     Unhealthy
```

A separate Bash script provides an additional layer of monitoring.

Every 5 minutes, Cron executes:

```bash
/opt/mlops-app/healthcheck.sh
```

The script:

1. Checks whether the `mlops-api` container is running.
2. Checks its Docker health status.
3. Starts the container if it is stopped.
4. Restarts the container if it is unhealthy.

The container also uses:

```text
--restart unless-stopped
```

This provides an additional Docker-level recovery mechanism.

## 🔐 Security

The EC2 security group exposes:

| Port | Purpose | Access |
|------|---------|--------|
| 22 | SSH | Administrator IP only |
| 8000 | FastAPI | Public |

SSH access is restricted using a `/32` CIDR rule rather than exposing SSH to the entire internet.

## 📁 Project Structure

```text
mlops-terraform-aws/
│
├── app/
│   ├── Dockerfile
│   ├── main.py
│   └── requirements.txt
│
├── scripts/
│   └── healthcheck.sh
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── .terraform.lock.hcl
│
├── .gitignore
└── README.md
```

## 🚀 Deployment

### Prerequisites

Install/configure:

- Terraform
- AWS CLI
- Docker
- Git
- An AWS account
- An SSH key pair

### Initialize Terraform

```bash
cd terraform
terraform init
```

### Format and validate

```bash
terraform fmt
terraform validate
```

### Preview infrastructure changes

```bash
terraform plan
```

### Deploy

```bash
terraform apply
```

Confirm with:

```text
yes
```

### View outputs

```bash
terraform output
```

Terraform provides:

```text
ec2_public_ip
api_url
health_url
```

## 🧪 Testing

### Test the API

```bash
curl http://YOUR_EC2_IP:8000
```

### Test the health endpoint

```bash
curl http://YOUR_EC2_IP:8000/health
```

### Check the Docker container

```bash
sudo docker ps
```

Expected container:

```text
mlops-api
```

### Check container health

```bash
sudo docker inspect \
  --format='{{.State.Health.Status}}' \
  mlops-api
```

Expected:

```text
healthy
```

## 🔄 Self-Healing Test

Stop the container:

```bash
sudo docker stop mlops-api
```

The Cron healthcheck detects that the container is no longer running and starts it again during the next scheduled execution.

The Docker restart policy also provides automatic recovery.

## 🧹 Cleanup

When the project is no longer needed, destroy the AWS infrastructure:

```bash
cd terraform
terraform destroy
```

Confirm with:

```text
yes
```

This prevents unnecessary AWS charges.

## 📌 What This Project Demonstrates

This project demonstrates practical experience with:

- Infrastructure as Code
- AWS cloud infrastructure
- Terraform provisioning
- EC2 administration
- Docker containerization
- REST API deployment
- Linux automation
- Health monitoring
- Self-healing infrastructure
- Security-group configuration
- Git/GitHub workflows

## 🔮 Future Improvements

Potential next steps:

- GitHub Actions CI/CD
- Amazon ECR for Docker image storage
- Automated image deployment
- HTTPS with a domain and reverse proxy
- CloudWatch monitoring and logging
- Infrastructure modules
- Remote Terraform state using S3
- Automated testing
- Model-serving capabilities

---

Built as a hands-on MLOps/DevOps learning project.
