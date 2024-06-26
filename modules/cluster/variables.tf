// mongodb atlas region
variable "atlas_region" {
  type    = string
  default = "US_EAST_1"
}

// name for atlas project
variable "atlas_project_name" {
  type    = string
  default = "terraformProject"
}

// atlas organisation id
variable "atlas_org_id" {
  type    = string
  default = "65e24d75b0bbab5dbe0ebe25"
}

// cidr value for atlas database
variable "atlas_cidr_block" {
  type    = string
  default = "192.168.0.0/21"
}

// username for mongodb atlas account
variable "username" {
  type    = string
  default = "user-1"
}

// name for mongodb atlas cluster
variable "mongodbatlas_cluster_name" {
  type = string
  default = "myFirstProject-Cluster"
}
