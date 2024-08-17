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

variable "aws_key_name" {
  description = "Name of the key pair"
  type        = string
  default     = "whitestack_key"
}

variable "aws_ami" {
  description = "AMI ID"
  type        = string
  default     = "ami-0075013580f6322a1"
}

variable "aws_instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "sg_from_port" {
  description = "Security group from port"
  type        = number
  default     = 22
}

variable "sg_to_port" {
  description = "Security group to port"
  type        = number
  default     = 22
}

variable "sg_protocol" {
  description = "Security group protocol"
  type        = string
  default     = "tcp"
}

variable "sg_cidr_blocks" {
  description = "Security group CIDR blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "aws_worker_nodes_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 1
}

variable "aws_instance_type_bastion" {
  description = "Instance type for bastion"
  type        = string
  default     = "t2.micro"
}