output "vpc_id" {
  description = "ID of the project VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}
output "ec2_public_ip" {
  description = "Public IP of the EC2 application server"
  value       = aws_instance.app.public_ip
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

output "rds_endpoint" {
  description = "RDS MySQL connection endpoint"
  value       = aws_db_instance.mysql.address
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}
output "ec2_instance_id" {
  description = "ID of the EC2 application server"
  value       = aws_instance.app.id
}

output "rds_instance_id" {
  description = "ID of the RDS MySQL instance"
  value       = aws_db_instance.mysql.id
}

output "ec2_security_group_name" {
  description = "Name of the EC2 security group"
  value       = aws_security_group.ec2.name
}

output "rds_security_group_name" {
  description = "Name of the RDS security group"
  value       = aws_security_group.rds.name
}

output "state_bucket_name" {
  description = "Name of the S3 Terraform state bucket"
  value       = "terraform-aws-infra-state-devsanghavi-119"
}
