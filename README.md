<h1> Terraform MongoDB Atlas DevOps Project </h1>

<h2> Project Overview </h2>

This Terraform project focuses on deploying a mongodb atlas cluster to mongodb atlas where it will contain a database. The project utlises two modules - one module is centred around the cluster itself, and the second module is setting up the Virtual Private Cloud (VPC) which will be used for a peering connection with the mongodb atlas cluster which will, in turn, further improve the security of the cluster via having more ways to access the cluster, and not just through connecting to the cluster using the command line interface or CLI. Datadog will be implemented to monitor the health and performance of the cluster to ensure that it is functioning as expected with regards to the number instances used and the compute size for some of the instances depending on the level of scalability that this cluster adopts. It is important to note that this project also adheres to the best secuirty practices with regards to using pre-commits to ensure that my terraform code or infrastructure does not have an security risks, and that it follows the best practice when it comes to securtiy. Terratests were utilised as a means to ensure module funactionality.

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
Database User: A database user with read and write access to the specific database is created. The password is generated securely and associated with the project






