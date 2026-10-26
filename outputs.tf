output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.main.id
}

output "ec2_instance_id" {
  value = aws_instance.app.id
}

output "ec2_private_ip" {
  value = aws_instance.app.private_ip
}

output "ssm_region" {
  value = var.aws_region
}

output "app_bucket" {
  value = aws_s3_bucket.artifacts.id
}

output "app_port_forward_command" {
  value = "aws ssm start-session --region ${var.aws_region} --target ${aws_instance.app.id} --document-name AWS-StartPortForwardingSession --parameters portNumber=${var.app_port},localPortNumber=${var.app_port}"
}
