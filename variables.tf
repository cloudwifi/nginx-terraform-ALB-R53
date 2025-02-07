variable "region" {
  description = "The AWS region to deploy the resources."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance."
  type        = string
  default     = "ami-0c614dee691cbbf37"
}

variable "instance_type" {
  description = "The type of EC2 instance to create."
  type        = string
  default     = "t2.micro"
}

variable "domain_name" {
  description = "The registered domain name in Route 53."
  type        = string
  default     = "cloudnet.click"
}

variable "hosted_zone_id" {
  description = "The Hosted Zone ID for the domain in Route 53."
  type        = string
  default     = "Z2R2S2X2"
}
