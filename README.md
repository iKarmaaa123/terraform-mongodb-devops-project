<h1> Terraform MongoDB Atlas DevOps Project </h1>

<h2> Project Overview </h2>

This Terraform project focuses on deploying a mongodb atlas cluster to mongodb atlas where it will contain a database. The project utlises two modules - one module is centred around the cluster itself, and the second module is setting up the Virtual Private Cloud (VPC) which will be used for a peering connection with the mongodb atlas cluster which will, in turn, further improve the security of the cluster via having more ways to access the cluster, and not just through connecting to the cluster using the command line interface or CLI. 

Datadog will be implemented to monitor the health and performance of the cluster to ensure that it is functioning as expected with regards to the number instances used and the compute size for some of the instances depending on the level of scalability that this cluster adopts. It is important to note that this project also adheres to the best secuirty practices with regards to using pre-commits to ensure that my terraform code or infrastructure does not have an security risks, and that it follows the best practice when it comes to securtiy. Terratests were utilised as a means to ensure module funactionality.

Now that I provided a brief overview for the project, I will delve into the various parts of the project, and discuss these parts in great depth as a way to give you, the reader, a deeper understanding of how this project is built, and how you can create this project for yourself as well.

<h2> Cluster Module </h2>
The cluster module comprises a number of files: .gitignore, cluster.tf, output.tf, terraform.tfvars, variables.tf, and versions.tf.

<h3> .gitignore file </h3>
This specific file ensures that no important files that contain sensitive information are pushed to the GitHub repository.

<h3> cluster.tf </h3>
This cluster.tf file contains a terraform configuration that sets up a MongoDB Atlas project with a secured databse cluster, user, and access control. The  following resources are created and configured:


MongoDB Atlas Project:
```hcl
resource "mongodbatlas_project" "atlas-project" {
  org_id = var.atlas_org_id
  name   = var.atlas_project_name
}
```
A new MongoDB Atlas project is created within the specified organization using the provided project name.

Database User:
```hcl
resource "mongodbatlas_database_user" "db-user" {
  username           = var.username
  password           = random_password.db-user-password.result
  project_id         = mongodbatlas_project.atlas-project.id
  auth_database_name = "admin"
  roles {
    role_name     = "readWrite"
    database_name = var.atlas_project_name
  }
}
```
A database user with read and write access to the specific database is created. The password is generated securely and associated with the project.

Database Password:
```hcl
resource "random_password" "db-user-password" {
  length           = 16
  special          = true
  override_special = "_%@"
}
```
A secure random password is generated for the database user, ensuring it contains special characters for added security.

Database IP Access List:
```hcl
resource "mongodbatlas_project_ip_access_list" "ip" {
  project_id = mongodbatlas_project.atlas-project.id
  ip_address = var.ip_address  
}
```
Access to the MongoDB Atlas cluster is restricted to the specified IP address, enhancing security by ensuring only trusted IPs can connect.

Atlas Advanced Cluster:
```hcl
resource "mongodbatlas_advanced_cluster" "atlas-cluster" {
  project_id             = mongodbatlas_project.atlas-project.id
  name                   = var.mongodbatlas_cluster_name
  cluster_type           = "REPLICASET"
  backup_enabled         = true
  mongo_db_major_version = "6.0"
  replication_specs {
    region_configs {
      electable_specs {
        instance_size = "M10"
        node_count    = 3
      }
      analytics_specs {
        instance_size = "M10"
        node_count    = 1
      }
      priority      = 7
      provider_name = "AWS"
      region_name   = "US_EAST_1"
    }
  }
}
```
A MongoDB Atlas advanced cluster is created with the following specifications:
Type: Replica set
Backup: Enabled
MongoDB Version 6.0
Replication Specs: Configured with an electable node set and analytic node set, both using AWS inthe 'US_EAST_1' region. The electable set consists of 3 nodes of size M10, and the analytics set consists of 1 node of M10.

<h3> Outputs </h3>
These outputs are primarily intended for use in Terratest with Go to validate various parts of the infrastructure:

MongoDB Atlas Project ID:
```hcl
output "mongodb_atlas_project_id" {
    value = mongodbatlas_project.atlas-project.id
}
```
Provides the ID of the created MongoDB Atlas project.

MongoDB Atlas CIDR Block:
```hcl
output "mongodb_atlas_cidr_block" {
    value = "192.168.0.0/21"
}
```
Provides the CIDR block used in the MongoDB Atlas project.

MongoDB Atlas Region:
```hcl
output "region_name" {
    value = "US_EAST_1"
}
```
Provides the region where the MongoDB Atlas cluster is deployed.

Project Name:
```hcl
output "project_name" {
  value = "terraformProject"
}
```
Provides the name of the Terraform project.

Organisation ID:
```hcl
output "organisation_id" {
  value = "65e24d75b0bbab5dbe0ebe25"
}
```
Provides the ID of the organisation in MongoDB Atlas.

<h3> Variables.tf </h3>
The following variables are used to configure the MongoDB Atlas project and its associated resources. Each variable has a default value which can be overridden as needed using a terraform.tfvars file (this will be shown in the following section):
MongoDB Atlas Region:

```hcl
variable "atlas_region" {
  type    = string
  default = "US_EAST_1"
}
```
Specifies the region where the MongoDB Atlas cluster will be deployed. The default region is US_EAST_1.

Atlas Project Name:
```hcl
variable "atlas_project_name" {
  type    = string
  default = "terraformProject"
}
```
The name of the MongoDB Atlas project. The default project name is terraformProject.

Atlas Organization ID:
```hcl
variable "atlas_org_id" {
  type    = string
  default = "65e24d75b0bbab5dbe0ebe25"
}
```
The organization ID for MongoDB Atlas. This ID is used to associate the project with the correct MongoDB Atlas organization. The default organization ID is 65e24d75b0bbab5dbe0ebe25.

CIDR Value for Atlas Database:
```hcl
variable "atlas_cidr_block" {
  type    = string
  default = "192.168.0.0/21"
}
```
Specifies the CIDR block for the MongoDB Atlas database. This is used for networking and access control purposes. The default CIDR block is 192.168.0.0/21.

Username for MongoDB Atlas Account:
```hcl
variable "username" {
  type    = string
  default = "user-1"
}
```
The username for the MongoDB Atlas database user account. This user will have access to the database. The default username is user-1.

MongoDB Atlas Cluster Name:
```hcl
variable "mongodbatlas_cluster_name" {
  type    = string
  default = "myFirstProject-Cluster"
}
```
The name of the MongoDB Atlas cluster. The cluster is where the databases will be hosted. The default cluster name is myFirstProject-Cluster.

IP Address for Database Access:
```hcl
variable "ip_address" {
  type = string
  default = "86.157.19.11"
}
```
The IP address allowed to access the MongoDB Atlas cluster. This is used for IP whitelisting to ensure only trusted IPs can connect to the database. The default IP address is 86.157.19.11.

<h3> Terraform.tfvars </h3>
To override the default values, create a terraform.tfvars file with your custom values:

```hcl
atlas_region           = "YOUR_CUSTOM_REGION"
atlas_project_name     = "YOUR_CUSTOM_PROJECT_NAME"
atlas_org_id           = "YOUR_CUSTOM_ORG_ID"
atlas_cidr_block       = "YOUR_CUSTOM_CIDR_BLOCK"
username               = "YOUR_CUSTOM_USERNAME"
mongodbatlas_cluster_name = "YOUR_CUSTOM_CLUSTER_NAME"
ip_address             = "YOUR_CUSTOM_IP_ADDRESS"
```
<h3> Versions.tf </h3>
This file is mostly used for defining the versions for both terraform, and the providers that you will be using in your own respective project. Here is a rundown of how this file is structured, and what each part of this configuration code means.

Terraform Block
The following terraform block specifies the required Terraform version and the providers necessary for this configuration. Each provider is essential for different aspects of the infrastructure setup:
```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.15.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}
```
required_version: Specifies the minimum required version of Terraform to use this configuration. In this case, the configuration requires Terraform version 1.0 or higher.

AWS Provider:
```hcl
aws = {
  source  = "hashicorp/aws"
  version = "~> 5.0"
}
```
The AWS provider is used to interact with the AWS services. In this configuration, it is necessary for provisioning and managing AWS infrastructure that supports the MongoDB Atlas cluster.

MongoDB Atlas Provider:
```hcl
mongodbatlas = {
  source  = "mongodb/mongodbatlas"
  version = "~> 1.15.0"
}
```
The MongoDB Atlas provider allows Terraform to manage MongoDB Atlas resources such as projects, clusters, and database users. This provider is critical for setting up and configuring the MongoDB Atlas environment.

Random Provider:
```hcl
random = {
  source  = "hashicorp/random"
  version = "~> 3.6.0"
}
```
The Random provider is used to generate random values, such as passwords. In this configuration, it is used to create secure random passwords for the MongoDB Atlas database users.








