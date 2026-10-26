variable "aws_region" {
  description = "AWS region in which to deploy infrastructure"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Prefix for AWS resource names"
  type        = string
  default     = "terraform-network"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "app_name" {
  description = "Name of the application deployed to EC2"
  type        = string
  default     = "demo"
}

variable "app_jar_path" {
  description = "Local path to the Spring Boot jar to deploy"
  type        = string
  default     = "~/Downloads/demo/target/demo-0.0.1-SNAPSHOT.jar"
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 8081
}
