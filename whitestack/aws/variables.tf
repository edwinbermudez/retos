variable "aws_profile" {
  description = "AWS Profile"
  type        = string
  default     = "test-account"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "aws_vpc" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_availability_zone" {
  description = "List of availability zones"
  type        = string
  default     = "us-west-2a,us-west-2b,us-west-2c"
}

variable "aws_subnet_private" {
  description = "List of CIDR blocks for the private subnet"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "aws_subnet_public" {
  description = "List of CIDR blocks for the public subnet"
  type        = list(string)
  default     = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
}