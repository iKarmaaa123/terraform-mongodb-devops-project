variable "provider_name" {
  type    = string
  default = "AWS"
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

// cidr block value for public subnet
variable "subnet_cidr_block" {
  type = string
  default = "10.0.0.0/24"
}

// name for vpc
variable "vpc_name" {
  type = string
  default = "mongodb-vpc"
}

// name for public subnet
variable "public_subnet_name" {
  type = string
  default = "mongodb-subnet"
}

variable "route_table_name" {
  type = string
  default = "mongodb-route-table"
}

// availability zone
variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}