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
🛠️ Tech Stack

* AWS EC2 — Application hosting
* Terraform — Infrastructure as Code
* Docker — Application containerization
* FastAPI — REST API
* Uvicorn — ASGI server
* Ubuntu 24.04 — EC2 operating system
* Bash — Health monitoring script
* Cron — Scheduled health monitoring
* Git/GitHub — Version control

✨ Features

Infrastructure as Code

Terraform provisions:

* AWS EC2 instance
* Ubuntu 24.04 AMI
* SSH key pair
* Security group
* Docker installation
* Application deployment

Containerized FastAPI Application

The API runs inside a Docker container:mlops-api

    └── FastAPI

         ├── /

         └── /health
API Endpoints

GET /

Returns:{

  "message": "MLOps API is running!",

  "status": "healthy"

}
GET /health

Returns:{
  "message": "MLOps API is running!",
  "status": "healthy"
}
GET /health

Returns:
{

  "status": "healthy"

}
The /health endpoint is also used by Docker’s container healthcheck.

❤️ Health Monitoring & Self-Healing

The Docker container has a built-in healthcheck:Every 30 seconds

       ↓

GET /health

       ↓

healthy?

   ↙       ↘

 YES       NO

  ↓         ↓

Continue   Docker

           health status
A separate Bash script provides an additional layer of monitoring.

Every 5 minutes, Cron executes:/opt/mlops-app/healthcheck.sh
The script:

1. Checks whether the mlops-api container is running.
2. Checks its Docker health status.
3. Restarts the container if it is stopped or unhealthy.

The container also uses:--restart unless-stopped
Security

The EC2 security group exposes:Port

Purpose

Access

22

SSH

Restricted to administrator IP

8000

FastAPI

Public
SSH access is restricted using a /32 CIDR rule rather than exposing port 22 to the entire internet.
Project Structure
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
Deployment

Prerequisites

Install/configure:

* Terraform
* AWS CLI
* Docker
* Git
* An AWS account
* An SSH key pair
Initialize Terraformcd terraform

terraform init
Validate configuration terraform fmt

terraform validate
Preview infrastructure changes terraform plan
Deploy terraform apply
Confirm with: yes
View outputs terraform output 
Testing

Check the API: curl http://YOUR_EC2_IP:8000
Check the health endpoint: curl http://YOUR_EC2_IP:8000/health
Check the Docker container:
sudo docker ps
Expected: mlops-api
Check container health: sudo docker inspect \

  --format='{{.State.Health.Status}}' \

  mlops-api
Expected:healthy
 Self-Healing Test

The monitoring system can be tested by stopping the container:
sudo docker stop mlops-api
The Cron healthcheck detects that the container is no longer running and starts it again.

The Docker restart policy provides an additional recovery mechanism.
Cleanup

When the project is no longer needed, destroy the AWS infrastructure:
cd terraform

terraform destroy
Confirm with: yes
This prevents unnecessary AWS charges.

📌 What This Project Demonstrates

This project demonstrates practical experience with:

* Infrastructure as Code
* AWS cloud infrastructure
* Terraform provisioning
* EC2 administration
* Docker containerization
* REST API deployment
* Linux automation
* Health monitoring
* Self-healing infrastructure
* Security-group configuration
* Git/GitHub workflows

🔮 Future Improvements

Potential next steps:

* GitHub Actions CI/CD
* Amazon ECR for Docker image storage
* Automated image deployment
* HTTPS with a domain and reverse proxy
* CloudWatch monitoring and logging
* Infrastructure modules
* Remote Terraform state using S3
* Automated testing
* Model-serving capabilities

⸻

Built as a hands-on MLOps/DevOps learning project.

