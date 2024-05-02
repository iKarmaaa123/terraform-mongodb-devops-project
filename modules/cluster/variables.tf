variable "provider_name" {
  type    = string
  default = "AWS"
}

variable "aws_account_id" {
  type    = string
  default = "648767092427"
}

variable "atlas_region" {
  type    = string
  default = "US-EAST-1"
}

variable "acceptor_region_name" {
  type    = string
  default = "US-EAST-1"
}

// internet gateway name
variable "internet_gateway_name" {
  type    = string
  default = "mongodb-internet-gateway"
}

// cidr block value for vpc
variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

// availability zone
variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}

// name for atlas project
variable "atlas_project_name" {
  type    = string
  default = "terraformProject"
}

// Atlas Organisation ID
variable "atlas_org_id" {
  type    = string
  default = "65e24d75b0bbab5dbe0ebe25"
}

// cidr value for atlas database
variable "atlas_cidr_block" {
  type    = string
  default = "192.168.0.0/21"
}

// Atlas Project Environment
variable "environment" {
  type    = string
  default = "Dev"
}

// username for mongodb atlas account
variable "username" {
  type    = string
  default = "user-1"
}