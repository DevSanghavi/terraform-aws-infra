# Terraform AWS Infrastructure

A hands-on AWS infrastructure project built with Terraform, Docker, GitHub Actions, Flask, Nginx, and Amazon RDS.

The project provisions a custom VPC, deploys a containerized Flask API behind Nginx on EC2, stores state remotely in S3, and automates both infrastructure deployment and application deployment through GitHub Actions.

## Live Health Check

After deployment, the application health endpoint is available at:

```text
http://<EC2_PUBLIC_IP>:8080/health
```

Expected response:

```json
{
  "environment": "production",
  "service": "terraform-aws-infra-api",
  "status": "healthy"
}
```

## Architecture

```text
                        Internet
                           |
                           v
              +-------------------------+
              |     EC2 Public Subnet    |
              |  EC2 t3.micro - Ubuntu   |
              |  Nginx :8080 -> Flask    |
              +-------------------------+
                           |
                           | MySQL :3306
                           v
              +-------------------------+
              |    Private Subnet A/B    |
              |   RDS MySQL db.t3.micro  |
              +-------------------------+

GitHub Actions:
- Docker CI -> Build and push image to GHCR
- Terraform CD -> terraform fmt, init, validate, plan, apply
- Deploy to EC2 -> Temporary SSH, Compose files, GHCR login, docker compose up

Terraform State:
- Stored in private versioned S3 bucket
- State locking enabled through S3 lock files
```

## AWS Components

| Component | Resource | Purpose |
|---|---|---|
| Network | VPC `10.0.0.0/16` | Isolated project network |
| Public subnet | `10.0.1.0/24` | Hosts EC2 and Nginx |
| Private subnet A | `10.0.2.0/24` | Hosts RDS |
| Private subnet B | `10.0.3.0/24` | Supports RDS subnet group |
| Internet Gateway | IGW | Public subnet internet routing |
| Compute | EC2 `t3.micro` | Runs Docker Compose stack |
| Database | RDS MySQL `db.t3.micro` | Private application database |
| Security | EC2 SG | Allows HTTP, HTTPS, port 8080, and restricted SSH |
| Security | RDS SG | Allows MySQL only from EC2 SG |
| State | S3 bucket | Stores encrypted, versioned Terraform state |
| CI/CD | GitHub Actions | Builds image, applies Terraform, deploys to EC2 |

## Repository Structure

```text
terraform-aws-infra/
├── .github/workflows/
│   ├── docker-ci.yml
│   ├── terraform-cd.yml
│   └── deploy-ec2.yml
├── app/
│   ├── Dockerfile
│   ├── app.py
│   ├── compose.yml
│   ├── requirements.txt
│   └── nginx/default.conf
├── backend.tf
├── compute.tf
├── database.tf
├── network.tf
├── outputs.tf
├── providers.tf
├── security.tf
├── terraform-deploy-policy.json
└── variables.tf
```

## CI/CD Workflows

| Workflow | Trigger | Purpose |
|---|---|---|
| Docker CI | Changes in `app/**` or workflow file | Builds and pushes image to GHCR |
| Terraform CD | Changes in `*.tf`, policy, or workflow file | Validates and applies Terraform |
| Deploy to EC2 | Successful Docker CI or manual dispatch | Deploys Compose stack to EC2 |

## Deployment Flow

1. Push application changes to `main`.
2. Docker CI builds and pushes the image to GHCR.
3. Deploy to EC2 starts after successful Docker CI.
4. GitHub Actions authorizes temporary SSH access for its runner IP.
5. Compose and Nginx configuration files are copied to EC2.
6. EC2 logs in to GHCR, pulls the latest image, and runs Docker Compose.
7. The workflow verifies `/health`.
8. Temporary SSH access is revoked.

## Cost Notes

This project is designed around AWS Free Tier, but actual charges depend on usage and account eligibility.

| Resource | Configuration | Cost consideration |
|---|---|---|
| EC2 | `t3.micro` | Free Tier eligible only within monthly hours and account limits |
| RDS | `db.t3.micro`, 20 GB | Free Tier eligible only within monthly hours and storage limits |
| S3 | Small Terraform state file | Very low cost, but versioning retains old versions |
| Data transfer | Public internet traffic | Can create charges beyond Free Tier allowances |
| Elastic IP | Not currently used | Avoid unattached Elastic IPs because they can bill hourly |

Cost controls used:

- `t3.micro` EC2 instance.
- `db.t3.micro` RDS instance.
- Single-AZ RDS deployment.
- No NAT Gateway.
- Private RDS deployment.
- GitHub Actions-hosted runners.
- Budget and billing alerts configured separately.

## Required GitHub Secrets

| Secret | Purpose |
|---|---|
| `AWS_ACCESS_KEY_ID` | Terraform and EC2 deployment access |
| `AWS_SECRET_ACCESS_KEY` | Terraform and EC2 deployment access |
| `DB_PASSWORD` | RDS master password |
| `GHCR_TOKEN` | GitHub Container Registry login |

## Local Development

```bash
cd app
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python app.py
```

Test locally:

```bash
curl http://127.0.0.1:5000/health
```

Run Docker Compose locally:

```bash
cd app
docker compose up -d --build
curl http://127.0.0.1:8080/health
docker compose down
```

## Terraform Commands

```bash
source .env
export AWS_PROFILE="$PROFILE"
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
```

## Cleanup Steps — Documentation Only

**Do not run these commands in this project.** They are documented only to show how the environment would be cleaned up after the learning project ends.

1. Stop the Docker Compose stack on EC2:

```bash
ssh ubuntu@<EC2_PUBLIC_IP>
docker compose -f /home/ubuntu/compose.yml down
```

2. Destroy Terraform-managed infrastructure:

```bash
terraform destroy
```

3. Confirm no project EC2 instances remain:

```bash
aws ec2 describe-instances --filters "Name=tag:Project,Values=terraform-aws-infra" --query "Reservations[].Instances[].InstanceId"
```

4. Confirm no project RDS instances remain:

```bash
aws rds describe-db-instances --query "DBInstances[].DBInstanceIdentifier"
```

5. Empty and delete the Terraform state bucket only after confirming no other project needs it:

```bash
aws s3 rm s3://terraform-aws-infra-state-devsanghavi-119 --recursive
aws s3 rb s3://terraform-aws-infra-state-devsanghavi-119
```

6. Delete the GitHub Actions deployment IAM user only after confirming it is no longer needed:

```bash
aws iam delete-user --user-name terraform-github-deploy
```

## Security Notes

- RDS is private and accepts MySQL only from the EC2 security group.
- SSH is restricted to the home IP, with temporary GitHub runner access only during deployment.
- Terraform state is encrypted and stored in a private S3 bucket.
- Sensitive values are stored in GitHub Actions secrets.
- `.env`, Terraform state, and `terraform.tfvars` are excluded from Git.
