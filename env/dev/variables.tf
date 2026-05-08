variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}
variable "ami_id" {
  description = "AMI ID for EC2 instances (Amazon Linux 2023 recommended)"
  type        = string
}
variable "app_name" {
    description = "name of app"
    type = string
  
}
variable "vpc_id" {
    type = string
  
}
variable "public_subnet_ids" {
    type = list(string)
  
}
variable "private_subnet_ids" {
    type = list(string)
  
}
variable "min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 4
}
variable "desired_capacity" {
  description = "Desired number of instances at launch"
  type        = number
  default     = 2
}