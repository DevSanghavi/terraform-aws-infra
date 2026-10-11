# Terraform AWS Infrastructure

Terraform project that provisions a secure AWS environment in `us-east-1`.

## Architecture

```text
Internet
   |
   v
[Public Subnet A] --> [EC2 Application Server]
   |                         |
   |                         v
   |                  [Private Subnet A] --> [RDS MySQL]
   |
   +--> [S3 Terraform State Bucket]

Security Groups:
- EC2 SG: HTTP/HTTPS from Internet, SSH from home IP
- RDS SG: MySQL 3306 only from EC2 SG
```

## Components

| Component | Purpose |
|---|---|
| VPC | Isolated AWS network |
| Public subnet | Hosts EC2 with internet access |
| Private subnet | Hosts RDS without direct internet access |
| Internet Gateway | Enables public-subnet internet access |
| NAT Gateway | Enables private-subnet outbound access |
| EC2 | Application server |
| RDS | Managed MySQL database |
| Security Groups | Control traffic between layers |
| S3 | Stores Terraform remote state |
| Terraform | Provisions all resources as code |

## Build Plan

| Project Day | Calendar Day | Topic |
|---|---:|---|
| 1 | 116 | Project planning and architecture |
| 2 | 117 | Terraform: VPC, 2 public subnets, IGW, route tables |
| 3 | 118 | Terraform: EC2 t3.micro, RDS db.t3.micro, Security Groups |
| 4 | 119 | S3 remote backend + outputs (resource IDs) |
| 5 | 120 | Flask API with /health endpoint |
| 6 | 121 | Dockerfile + compose.yml (Flask + Nginx proxy) |
| 7 | 122 | CI: GitHub Actions build image, push to GHCR |
| 8 | 123 | CD: GitHub Actions runs terraform apply |
| 9 | 124 | CD: GitHub Actions SSH into EC2, docker compose up |
| 10 | 125 | Documentation: architecture diagram, costs, destroy steps (docs only, never run) |

## Safety

- Never run `terraform destroy`.
- Never delete project resources.
- Keep AWS credentials out of Git.
- Use least-privilege security groups.
