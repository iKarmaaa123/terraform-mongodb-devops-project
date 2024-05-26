<h1> Terraform MongoDB Atlas DevOps Project </h1>

<h2> Project Overview </h2>

This Terraform project focuses on deploying a mongodb atlas cluster to mongodb atlas where it will contain a database. The project utlises two modules - one module is centred around the cluster itself, and the second module is setting up the Virtual Private Cloud (VPC) which will be used for a peering connection with the mongodb atlas cluster which will, in turn, further improve the security of the cluster via having more ways to access the cluster, and not just through connecting to the cluster using the command line interface or CLI. 

Datadog will be implemented to monitor the health and performance of the cluster to ensure that it is functioning as expected with regards to the number instances used and the compute size for some of the instances depending on the level of scalability that this cluster adopts. It is important to note that this project also adheres to the best secuirty practices with regards to using pre-commits to ensure that my terraform code or infrastructure does not have an security risks, and that it follows the best practice when it comes to securtiy. Terratests were utilised as a means to ensure module funactionality.

Now that I provided a brief overview for the project, I will delve into the various parts of the project, and discuss these parts in great depth as a way to give you, the reader, a deeper understanding of how this project is built, and how you can create this project for yourself as well.

<h2> Cluster Module </h2>
The cluster module comprises a number of files: .gitignore, cluster.tf, output.tf, terraform.tfvars, variables.tf, and versions.tf.

<h2> .gitignore file </h2>
This specific file ensures that no important files that contain sensitive information are pushed to the GitHub repository.

<h2> cluster.tf </h2>
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

<h2> Outputs </h2>
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

<h2> Variables.tf </h2>
The following variables are used to configure the MongoDB Atlas project and its associated resources. Each variable has a default value which can be overridden as needed using a terraform.tfvars file (this will be shown in the following section):
```hcl
variable "atlas_region" {
  type    = string
  default = "US_EAST_1"
}
```



<h2> Terraform.tfvars </h2>
These are the custom variable names that you should use for the project:

```hcl
provider_name         = "AWS"
atlas_region          = "US_EAST_1"
acceptor_region_name  = "US_EAST_1"
atlas_org_id          = "65e24d75b0bbab5dbe0ebe25"
environment           = "dev"
ip_address            = "86.139.204.225"
```
Change the values for the custom variables for your own project.







