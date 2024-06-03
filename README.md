<h1> Terraform MongoDB Atlas DevOps Project </h1>

<h2> Project Overview </h2>

This Terraform project focuses on deploying a MongoDB Atlas cluster to MongoDB Atlas, housing a database. The project utilizes two modules: one for the cluster itself and another for setting up the Virtual Private Cloud (VPC). The VPC enables a peering connection with the MongoDB Atlas cluster, thus enhancing security by establishing a reliable connection that is happening over a private network.

Datadog is integrated to monitor the database's health and performance as well as the cluster's, ensuring it operates optimally amidst scalability adjustments. The project adheres to security best practices by employing pre-commits to mitigate potential security risks in the Terraform code. Additionally, Terratests validate module functionality to ensure that they are working as intended.

Now, let's delve into each project component, providing an in-depth understanding for viewers interested in replicating this project.

<h2> Exporting Credentials </h2>
When working with providers like MongoDB Atlas and AWS, having a set of credentials that grants programmatic access to these platforms is crucial. Without these credentials, deploying necessary resources to these platforms will be impossible. The following credentials need to be exported using a Windows terminal:

```hcl
export MONGODB_ATLAS_PUBLIC_KEY="<insert your public key here>"
export MONGODB_ATLAS_PRIVATE_KEY="<insert your private key here>"
```

```hcl
export AWS_ACCESS_KEY_ID="<INSERT YOUR KEY HERE>"
export AWS_SECRET_ACCESS_KEY="<INSERT YOUR KEY HERE>"
export AWS_DEFAULT_REGION="<INSERT AWS REGION HERE>"
```
<h2> Cluster Module </h2>
The cluster module comprises a number of files: .gitignore, cluster.tf, output.tf, terraform.tfvars, variables.tf, and versions.tf.

Here is a graphic that shows the directory structure for this module directory:

```hcl
cluster/
├── .gitignore
├── cluster.tf
├── output.tf
├── terraform.tfvars
├── variables.tf
└── versions.tf
```
<h3> .gitignore file </h3>
- This specific file ensures that no important files that contain sensitive information or files that take up a lot of storage are pushed to the GitHub repository.

<h3> cluster.tf </h3>
- This cluster.tf file contains a terraform configuration that sets up a MongoDB Atlas project with a secured databse cluster, user, and access control. The following resources are created and configured:

<h4> MongoDB Atlas Project </h4>

```hcl
resource "mongodbatlas_project" "atlas-project" {
  org_id = var.atlas_org_id
  name   = var.atlas_project_name
}
```
- A new MongoDB Atlas project is created within the specified organization using the provided project name.

<h4> Database User </h4>

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
- A database user with read and write access to the specific database is created. The password is generated securely and associated with the project.

<h4> Database Password </h4>

```hcl
resource "random_password" "db-user-password" {
  length           = 16
  special          = true
  override_special = "_%@"
}
```
- A secure random password is generated for the database user, ensuring it contains special characters for added security.

Database IP Access List:

```hcl
resource "mongodbatlas_project_ip_access_list" "ip" {
  project_id = mongodbatlas_project.atlas-project.id
  ip_address = var.ip_address  
}
```
- Access to the MongoDB Atlas cluster is restricted to the specified IP address, enhancing security by ensuring only trusted IPs can connect.

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
- A MongoDB Atlas advanced cluster is created with the following specifications:
Type: Replica set
Backup: Enabled
MongoDB Version 6.0
Replication Specs: Configured with an electable node set and analytic node set, both using AWS inthe 'US_EAST_1' region. The electable set consists of 3 nodes of size M10, and the analytics set consists of 1 node of M10.

<h3> Outputs </h3>
- These outputs are primarily intended for use in Terratest with Go to validate various parts of the infrastructure:

<h4> MongoDB Atlas Project ID </h4>
```hcl
output "mongodb_atlas_project_id" {
    value = mongodbatlas_project.atlas-project.id
}
```
-Provides the ID of the created MongoDB Atlas project.

<h4> MongoDB Atlas CIDR Block </h4>
```hcl
output "mongodb_atlas_cidr_block" {
    value = "192.168.0.0/21"
}
```
- Provides the CIDR block used in the MongoDB Atlas project.

<h4> MongoDB Atlas Region </h4>
```hcl
output "region_name" {
    value = "US_EAST_1"
}
```
- Provides the region where the MongoDB Atlas cluster is deployed.

<h4> Project Name </h4>

```hcl
output "project_name" {
  value = "terraformProject"
}
```
- Provides the name of the Terraform project.

<h4> Organisation ID </h4>

```hcl
output "organisation_id" {
  value = "65e24d75b0bbab5dbe0ebe25"
}
```
- Provides the ID of the organisation in MongoDB Atlas.

<h3> Variables.tf </h3>
The following variables are used to configure the MongoDB Atlas project and its associated resources. Each variable has a default value which can be overridden as needed using a terraform.tfvars file (this will be shown in the following section):
<h4> MongoDB Atlas Region </h4>

```hcl
variable "atlas_region" {
  type    = string
  default = "US_EAST_1"
}
```
- Specifies the region where the MongoDB Atlas cluster will be deployed. The default region is US_EAST_1.

<h4> Atlas Project Name </h4>
```hcl
variable "atlas_project_name" {
  type    = string
  default = "terraformProject"
}
```
- The name of the MongoDB Atlas project. The default project name is terraformProject.

<h4> Atlas Organization ID </h4>
```hcl
variable "atlas_org_id" {
  type    = string
  default = "65e24d75b0bbab5dbe0ebe25"
}
```
- The organization ID for MongoDB Atlas. This ID is used to associate the project with the correct MongoDB Atlas organization. The default organization ID is 65e24d75b0bbab5dbe0ebe25.

<h4> CIDR Value for Atlas Database </h4>
```hcl
variable "atlas_cidr_block" {
  type    = string
  default = "192.168.0.0/21"
}
```
- Specifies the CIDR block for the MongoDB Atlas database. This is used for networking and access control purposes. The default CIDR block is 192.168.0.0/21.

<h4> Username for MongoDB Atlas Account </h4>

```hcl
variable "username" {
  type    = string
  default = "user-1"
}
```
- The username for the MongoDB Atlas database user account. This user will have access to the database. The default username is user-1.

<h4> MongoDB Atlas Cluster Name </h4>

```hcl
variable "mongodbatlas_cluster_name" {
  type    = string
  default = "myFirstProject-Cluster"
}
```
- The name of the MongoDB Atlas cluster. The cluster is where the databases will be hosted. The default cluster name is myFirstProject-Cluster.

<h4> IP Address for Database Access </h4>

```hcl
variable "ip_address" {
  type = string
  default = "86.157.19.11"
}
```
- The IP address allowed to access the MongoDB Atlas cluster. This is used for IP whitelisting to ensure only trusted IPs can connect to the database. The default IP address is 86.157.19.11.

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

<h4> Terraform Block </h4>
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
<h4> required_version </h4>

- Specifies the minimum required version of Terraform to use this configuration. In this case, the configuration requires Terraform version 1.0 or higher.

<h4> AWS Provider </h4>

```hcl
aws = {
  source  = "hashicorp/aws"
  version = "~> 5.0"
}
```
- The AWS provider is used to interact with the AWS services. In this configuration, it is necessary for provisioning and managing AWS infrastructure that supports the MongoDB Atlas cluster.

<h4> MongoDB Atlas Provider </h4>

```hcl
mongodbatlas = {
  source  = "mongodb/mongodbatlas"
  version = "~> 1.15.0"
}
```
- The MongoDB Atlas provider allows Terraform to manage MongoDB Atlas resources such as projects, clusters, and database users. This provider is critical for setting up and configuring the MongoDB Atlas environment.

<h4> Random Provider </h4>

```hcl
random = {
  source  = "hashicorp/random"
  version = "~> 3.6.0"
}
```
- The Random provider is used to generate random values, such as passwords. In this configuration, it is used to create secure random passwords for the MongoDB Atlas database users.

<h2> Benefits of Using MongoDB Atlas for Your Database </h2>

- Before moving onto the 'VPC' module segment, it is important that we explore the benefits of using a mongodb atlas cluster for your database - particularly, some of the security and scalability benefits that it brings as well.

- MongoDB Atlas is a fully managed cloud database service that provides a variety of benefits for developers and organizations. Here are some of the key advantages of housing your database within MongoDB Atlas

<h4> Fully Managed Service </h4>

- Ease of Management: MongoDB Atlas handles database operations such as provisioning, patching, and scaling, reducing the administrative overhead.

- Automated Backups: Regular automated backups with point-in-time recovery ensure your data is safe and recoverable.

<h4> High Availability and Reliability </h4>

- Built-In Replication: Atlas provides automated replication across multiple availability zones, ensuring high availability and fault tolerance.

- Self-Healing Clusters: Automatically detects and recovers from node failures, ensuring minimal downtime.

<h4> Scalability </h4>

- Horizontal Scaling: Easily scale out your database by adding more shards to distribute data and workload.

- Vertical Scaling: Increase the capacity of your database instances with a few clicks without downtime.

<h4> Security </h4>

- End-to-End Encryption: Data is encrypted at rest and in transit, ensuring data security.

- Compliance: MongoDB Atlas complies with various standards such as GDPR, HIPAA, and SOC 2, making it suitable for sensitive data.

<h4> Global Distribution </h4>

- Multi-Region Deployments: Deploy your database across multiple regions to provide low-latency access to users worldwide.

- Global Clusters: Automatically route read and write operations to the nearest data center.

<h4> Integrated Tools </h4>

- Data Visualization: Built-in tools like MongoDB Charts allow for easy visualization of your data.

- Monitoring and Alerts: Comprehensive monitoring and alerting systems to keep track of database performance and health.

<h4> Cost-Effectiveness </h4>

- Pay-As-You-Go Pricing: Flexible pricing model that allows you to pay only for the resources you use.

- Operational Efficiency: Reduces the need for a dedicated DBA team, lowering operational costs.

<h2> VPC Module </h2>

- Now that we have discussed about the various contents of the 'cluster' module, we will now discuss about the 'VPC' module which will create the resources needed for the vpc infrastructure that is going to have a peering connection with our mongodb atlas cluster.

- Here is a graphical visualisation of what the VPC module looks like:
```hcl
vpc/
├── .gitignore
├── output.tf
├── terraform.tfvars
├── variables.tf
└── vpc.tf
```
<h3> vpc.tf </h3>

- The following resources are used to set up a Virtual Private Cloud (VPC) and associated networking components in AWS using Terraform. Each resource is configured with specific parameters and tags:

AWS VPC:

```hcl
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_name
  }
}
```
- Creates a new Virtual Private Cloud (VPC) with the specified CIDR block and name.

AWS Default Security Group:
```hcl
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    protocol  = "-1"
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    protocol    = "-1"
    self        = true
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
- Configures the default security group for the VPC to allow all inbound and outbound traffic.

AWS Subnet:
```hcl
resource "aws_subnet" "my_subnet" {
  cidr_block = var.subnet_cidr_block
  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = var.availability_zone

  tags = {
    Name = var.public_subnet_name
  }
}
```
- Creates a new subnet within the specified VPC, CIDR block, and availability zone.

AWS Internet Gateway:
```hcl
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.internet_gateway_name
  }
}
```
- Creates an Internet Gateway for the VPC, allowing the VPC to connect to the internet.

AWS Route Table:
```hcl
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = var.route_table_name
  }
}
```
- Creates a route table for the VPC with a route that directs all traffic to the Internet Gateway.

AWS Route Table Association:
```hcl
resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}
```
- Associates the specified subnet with the route table, enabling the subnet to use the routes defined in the route table.

<h3> Variables.tf </h3>
- The following variables are used to configure the AWS VPC and its associated resources. Each variable has a default value which can be overridden as needed.

Provider Name:
```hcl
variable "provider_name" {
  type    = string
  default = "AWS"
}
```
- Specifies the cloud provider to use. The default value is AWS.

Internet Gateway Name:
```hcl
variable "internet_gateway_name" {
  type    = string
  default = "mongodb-internet-gateway"
}
```
- The name tag for the Internet Gateway. The default name is mongodb-internet-gateway.

VPC CIDR Block:
```hcl
variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}
```
Specifies the CIDR block for the VPC. The default value is 10.0.0.0/16.

Public Subnet CIDR Block:
```hcl
variable "subnet_cidr_block" {
  type = string
  default = "10.0.0.0/24"
}
```
 - Specifies the CIDR block for the public subnet within the VPC. The default value is 10.0.0.0/24.

 VPC Name:
 ```hcl
 variable "vpc_name" {
  type = string
  default = "mongodb-vpc"
}
```
- The name tag for the VPC. The default name is mongodb-vpc.

Public Subnet Name:
 ```hcl
variable "public_subnet_name" {
  type = string
  default = "mongodb-subnet"
}
 ```
- The name tag for the public subnet. The default name is mongodb-subnet.

Route Table Name:
```hcl
variable "route_table_name" {
  type = string
  default = "mongodb-route-table"
}
```
- The name tag for the route table. The default name is mongodb-route-table.

Availability Zone:
```hcl
variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}
```
- Specifies the availability zone for the subnet. The default value is us-east-1a.

<h3> Terraform.tfvars </h3>

- To override the default values, create a terraform.tfvars file with your custom values:

```hcl
provider_name          = "YOUR_CUSTOM_PROVIDER_NAME"
internet_gateway_name  = "YOUR_CUSTOM_INTERNET_GATEWAY_NAME"
vpc_cidr_block         = "YOUR_CUSTOM_VPC_CIDR_BLOCK"
subnet_cidr_block      = "YOUR_CUSTOM_SUBNET_CIDR_BLOCK"
vpc_name               = "YOUR_CUSTOM_VPC_NAME"
public_subnet_name     = "YOUR_CUSTOM_PUBLIC_SUBNET_NAME"
route_table_name       = "YOUR_CUSTOM_ROUTE_TABLE_NAME"
availability_zone      = "YOUR_CUSTOM_AVAILABILITY_ZONE"
```
<h3> Outputs.tf </h3>

- The following outputs provide essential information about the AWS VPC and its associated resources. Some of these outputs are primarily intended for use in Terratests to validate the infrastructure setup:

VPC ID:
```hcl
output "vpc_id" {
    value = aws_vpc.my_vpc.id
}
```
The output for the ID of the created VPC.

Route Table CIDR Block:
```hcl
output "route_table_cidr_block" {
    value = aws_vpc.my_vpc.cidr_block
}
```
- The output for the CIDR block of the VPC associated with the route table.

Route Table ID:
```hcl
output "route_table_id" {
    value = aws_route_table.my_route_table.id
}
```
- The output for the ID of the created route table.

AWS Account ID:
```hcl
output "aws_account_id" {
    value = "648767092427"
}
```
- The AWS account ID. This is a static value representing the account under which the resources are created. This output can be used in Terratests to confirm that the resources are being created in the correct AWS account.

<h2> main </h2>

- The main directory will combine the work we did in the 'cluster' module directory and 'VPC' module directory. I will not provide a overview for the .gitignore file or the versions.tf file as they have already been provided explained. Here is an overview of what the directory structure looks like:

```hcl
# Directory structure for 'main' directory
main/
├── .gitignore
├── main.tf
└── versions.tf
```

<h3> main.tf </h3>
This configuration sets up a MongoDB Atlas cluster and an AWS VPC, then establishes a network peering connection between them.

MongoDB Atlas Cluster Module:

```hcl
module "cluster" {
    source = "../modules/cluster"
}
```
This module sets up the MongoDB Atlas cluster. The source points to the cluster module directory.

AWS VPC Module:

```hcl
module "vpc" {
    source = "../modules/vpc"
}
```

MongoDB Atlas Network Peering:

resource "mongodbatlas_network_peering" "peering" {
  project_id             = module.cluster.mongodb_atlas_project_id
  atlas_cidr_block       = module.cluster.mongodb_atlas_cidr_block
  container_id           = mongodbatlas_network_container.test.id
  accepter_region_name   = "US_EAST_1"
  provider_name          = "AWS"
  route_table_cidr_block = module.vpc.route_table_cidr_block
  vpc_id                 = module.vpc.vpc_id
  aws_account_id         = module.vpc.aws_account_id
}
This resource creates a network peering connection between the MongoDB Atlas cluster and the AWS VPC.

MongoDB Atlas Network Container:
```hcl
resource "mongodbatlas_network_container" "test" {
  project_id       = module.cluster.mongodb_atlas_project_id
  atlas_cidr_block = module.cluster.mongodb_atlas_cidr_block
  provider_name    = "AWS"
  region_name      = "US_EAST_1"
}
```
This resource creates a network container for the MongoDB Atlas cluster, necessary for peering.

AWS VPC Peering Connection Accepter:
```hcl
resource "aws_vpc_peering_connection_accepter" "peering_accept" {
  vpc_peering_connection_id = mongodbatlas_network_peering.peering.connection_id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}
```
This resource accepts the VPC peering connection request from MongoDB Atlas.

AWS Route to MongoDB Atlas:
```hcl
resource "aws_route" "to_mongodb_atlas" {
  route_table_id            = module.vpc.route_table_id
  destination_cidr_block    = mongodbatlas_network_peering.peering.atlas_cidr_block
  vpc_peering_connection_id = mongodbatlas_network_peering.peering.connection_id
}
```
This resource creates a route in the AWS route table to the MongoDB Atlas cluster through the VPC peering connection.

Before moving onto the section that is revolved around the CI/CD pipeline for this project and what tool was employed to do this, it would make sense to provide an overview for the various benefits of establishing a peering connection between a vpc and a mongodb atlas database.

<h2> Benefits of Using a Peering Connection Between VPC and MongoDB Atlas Cluster </h2>
Establishing a peering connection between your AWS VPC (Virtual Private Cloud) and your MongoDB Atlas cluster provides several advantages, enhancing the overall performance, security, and manageability of your infrastructure. Here are some of the key benefits:

<h4>Enhanced Security </h4>
Private Network Communication: Peering connections allow your VPC to communicate with the MongoDB Atlas cluster over a private network, eliminating exposure to the public internet and reducing the risk of attacks.

Controlled Access: By using security groups and network ACLs (Access Control Lists), you can define strict access controls, ensuring that only authorized instances within your VPC can access the database.

<h4> Improved Performance </h4>
Low Latency: Direct communication through a peering connection reduces network latency, leading to faster data access and improved application performance.

High Bandwidth: Peering connections typically offer higher bandwidth compared to public internet connections, enabling efficient data transfer and handling larger volumes of data traffic.

<h4> Cost Savings </h4>
Reduced Data Transfer Costs: Data transfer between your VPC and the MongoDB Atlas cluster over a peering connection is usually cheaper compared to transferring data over the internet.

No NAT Gateway Costs: Eliminates the need for a NAT (Network Address Translation) gateway to facilitate communication between your VPC and the Atlas cluster, further reducing costs.

<h2> .github/workflows </h2>
This directory contains the CI/CD(continuous integration and continuous delivery) pipeline used to deployed the resources for this project to both MongoDB atlas and AWS.

<h2> Simplified Network Architecture </h2>
Direct Connectivity: Peering connections provide a straightforward network setup, enabling seamless integration between your application servers in the VPC and the MongoDB Atlas cluster.

Consistent IP Addressing: Maintains consistent IP addressing, making network management and troubleshooting simpler.

<h4> Increased Reliability </h4>
Stable Connectivity: Private connections are less susceptible to internet outages and fluctuations, offering more stable and reliable connectivity.

Redundancy: You can configure multiple peering connections for redundancy, ensuring high availability and resilience in your network architecture.

<h4> Enhanced Compliance </h4>
Regulatory Requirements: Many compliance standards and regulations require that sensitive data be transferred over private networks rather than the public internet. Peering connections help meet these regulatory requirements.

Data Sovereignty: Ensures that data stays within the geographic boundaries of your cloud provider's infrastructure, supporting data sovereignty policies.

<h4> Seamless Integration </h4>
Consistent Network Policies: Allows you to apply consistent network policies and monitoring across your VPC and MongoDB Atlas cluster, streamlining operations and improving security posture.

Compatibility: Fully compatible with other AWS services, allowing for seamless integration with your existing AWS infrastructure.

By leveraging a peering connection between your AWS VPC and MongoDB Atlas cluster, you can achieve a more secure, efficient, and reliable setup for your database applications. This integration not only enhances performance but also simplifies network management and helps meet compliance requirements, making it an essential component of a robust cloud architecture.

<h3> GitHub Actions Workflow for Terraform </h3>

This GitHub Actions workflow automates the deployment of your Terraform configurations whenever there is a push to the repository. It sets up the necessary environment, checks out the code, and runs the Terraform commands to initialize, plan, and apply the configurations.

This workflow ensures that your Terraform configurations are automatically deployed and managed whenever there is a change in the repository, leveraging the capabilities of GitHub Actions for CI/CD.

```hcl
name: 'Terraform'

on: push

permissions:
  contents: read

env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  AWS_REGION: "us-east-1"
  MONGODB_ATLAS_PUBLIC_KEY: ${{ secrets.MONGODB_ATLAS_PUBLIC_KEY }}
  MONGODB_ATLAS_PRIVATE_KEY: ${{ secrets.MONGODB_ATLAS_PRIVATE_KEY }}
  MONGODB_REGION: "US-EAST-1"

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Get IP Addresses
        uses: candidob/get-runner-ip@v1.0.0

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v1

      - name: Terraform init
        id: init
        run: |
          cd main
          terraform init

      - name: Terraform plan
        id: plan
        run: |
          cd main
          terraform plan

      - name: Terraform apply
        id: apply
        run: |
          cd main
          terraform apply -auto-approve

  ```
Trigger:

```hcl
on: push
```
The workflow is triggered by any push to the repository.

Permissions:
```hcl
permissions:
  contents: read
```
Sets the permissions for the workflow. In this case, it allows read access to the contents.

Environment Variables:
```hcl
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  AWS_REGION: "us-east-1"
  MONGODB_ATLAS_PUBLIC_KEY: ${{ secrets.MONGODB_ATLAS_PUBLIC_KEY }}
  MONGODB_ATLAS_PRIVATE_KEY: ${{ secrets.MONGODB_ATLAS_PRIVATE_KEY }}
  MONGODB_REGION: "US-EAST-1"
```
Sets the environment variables needed for AWS and MongoDB Atlas authentication using secrets stored in GitHub.

Jobs:
```hcl
jobs:
  build:
    runs-on: ubuntu-latest
```
Defines the build job that runs on the latest version of Ubuntu. A job is a set of steps in a workflow that is executed on the same runner. Each step is either a shell script that will be executed, or an action that will be run. Steps are executed in order and are dependent on each other. Since each step is executed on the same runner, you can share data from one step to another.

Checkout Code:

```hcl
- name: Checkout
  uses: actions/checkout@v3
```
This step uses the checkout action to clone the repository's code into the GitHub Actions runner.

Get IP Addresses:

```hcl
- name: Get IP Addresses
  uses: candidob/get-runner-ip@v1.0.0
```
This step uses the get-runner-ip action to retrieve the IP addresses of the GitHub Actions runner. This might be useful for configuring access lists or security groups.

Set Up Terraform:

```hcl
- name: Set up Terraform
  uses: hashicorp/setup-terraform@v1
```
This step uses the setup-terraform action to install the specified version of Terraform CLI on the runner, ensuring the correct version is used.

<h4> Terraform Init </h4>
```hcl
- name: Terraform init
  id: init
  run: |
    cd main
    terraform init
```
This step initializes the Terraform configuration in the main directory by running the terraform init command. It downloads the necessary provider plugins and sets up the backend configuration.

Terraform Plan:
```hcl
- name: Terraform plan
  id: plan
  run: |
    cd main
    terraform plan
```
This step creates an execution plan for Terraform by running the terraform plan command in the main directory. It shows what actions Terraform will take to achieve the desired state defined in the configuration files.

Terraform Apply:
```hcl
- name: Terraform apply
  id: apply
  run: |
    cd main
    terraform apply -auto-approve
```
This step applies the Terraform configuration by running the terraform apply -auto-approve command in the main directory. The -auto-approve flag automatically approves the changes without waiting for manual confirmation.

<h2> tests </h2>
Within this directory we will discuss about the various terratests used for testing various aspects of my infrastructure. Here is an overview of what this directory structure looks like:

```hcl
tests/
├── examples/
├── .gitignore
├── aws_account_number_test.go
├── organisation_id_test.go
├── project_name_test.go
├── subnet_cidr_block_value_test.go
└── vpc_cidr_block_value_test.go
```
Now we will provide a in-depth view of all the files present within the tests directory.

<h2> .gitignore </h2>
Within this file we are choosing to ignore files such as the .terraform, go.mod and go.sum. These are files that take up way too much storage, and will cause issues when trying to deploy them to your respective github repo.

<h2> aws_account_number_test.go </h2>
This Go test file uses the Terratest library to test the Terraform configuration for the AWS account number value. The test ensures that the Terraform configuration is applied correctly and that the output matches the expected AWS account ID. I will not be breaking down the following terratests as those terratests are the exact same as this terratest, but with different parameters. Understand how to run this test first, and then all the tests, henceforth, will be easier to run.

```hcl
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAWSAccountNumberValue(t *testing.T) {
	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "./examples/vpc",
	})

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables and check they have the expected values.
	output := terraform.Output(t, terraformOptions, "aws_account_id")
	assert.Equal(t, "648767092427", output)
}
```
<h4> Package Declaration </h4>

```hcl
package test
```
Declares the package name for the test file. In this case, the package is named test.

<h4> Import Statements </h4>

```hcl
import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)
```
Imports the necessary packages:

testing: Provides support for automated testing of Go packages.

terraform: Provides helper functions for running Terraform commands in tests.

assert: Provides assertion functions for testing.

<h4> Test Function </h4>

```hcl
func TestAWSAccountNumberValue(t *testing.T) {
```
Defines the test function TestAWSAccountNumberValue which will run the test. The t *testing.T parameter is used to log errors and report test failures.

<h4> Terraform Options </h4>

```hcl
terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
	// Set the path to the Terraform code that will be tested.
	TerraformDir: "./examples/vpc",
})
```
Constructs the Terraform options with default retryable errors. It sets the path to the Terraform code that will be tested ("./examples/vpc").

<h4> Clean Up Resources </h4>

```hcl
defer terraform.Destroy(t, terraformOptions)
```
Schedules a cleanup of resources with terraform destroy at the end of the test, ensuring that any resources created during the test are destroyed.

<h4> Initialize and Apply Terraform Configuration </h4>

```hcl
terraform.InitAndApply(t, terraformOptions)
```
Runs terraform init and terraform apply. If there are any errors during these operations, the test will fail.

<h4> Check Output Values </h4>

```hcl
output := terraform.Output(t, terraformOptions, "aws_account_id")
assert.Equal(t, "648767092427", output)
```
Runs terraform output to get the value of the aws_account_id output variable and checks that it matches the expected value (648767092427). If the output value does not match, the test will fail.

<h2> organisation_id_test.go </h2>
This terratest will also test to see if we are deploying the mongodb cluster resources to the correct organsation within mongodb atlas.

```hcl
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestMongodbAtlasOrganisationId(t *testing.T) {
	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "./examples/cluster",
	})

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables and check they have the expected values.
	output := terraform.Output(t, terraformOptions, "organisation_id")
	assert.Equal(t, "65e24d75b0bbab5dbe0ebe25", output)
}
```
<h2> project_name_test.go </h2>
This terratest will also test to see if we are deploying the mongodb cluster resources to the correct project within mongodb atlas.

```hcl
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestMongodbProjectName(t *testing.T) {
	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "./examples/cluster",
	})

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables and check they have the expected values.
	output := terraform.Output(t, terraformOptions, "project_name")
	assert.Equal(t, "terraformProject", output)
}
```
<h2> subnet_cidr_block_value_test.go </h2>
This terratest will also test to see if we are working with the correct subnet cidr block value when deploying our resources to AWS.

```hcl
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestSubnetCidrBlockValue(t *testing.T) {
	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "./examples/vpc",
	})

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables and check they have the expected values.
	output := terraform.Output(t, terraformOptions, "subnet_cidr_block")
	assert.Equal(t, "10.0.0.0/24", output)
```

<h2> vpc_cidr_block_value_test.go </h2>
This terratest will also test to see if we are working with the correct VPC cidr block value when deploying our resources to AWS.

```hcl
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestVpcCidrBlockValue(t *testing.T) {
	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "./examples/vpc",
	})

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables and check they have the expected values.
	output := terraform.Output(t, terraformOptions, "vpc_cidr_block")
	assert.Equal(t, "10.0.0.0/16", output)
}
```
<h4> Examples directory </h4>
The 'examples' directory contains the 2 modules that were explained previously - this being the 'cluster' module and 'vpc' module. The contents within these 2 modules in the example directory are the exact same as those present in 'examples' directory and, therefore, do not need breakdown. These are the two modules that I decided to test to ensure adequate module functionality.

<h2> Pre-commits file </h2>
This configuration file sets up pre-commit hooks to ensure consistent and secure Terraform code. Pre-commit hooks are scripts that run before a commit is made, helping to enforce code quality and standards.

```hcl
repos:
  - repo: https://github.com/terraform-docs/terraform-docs
    rev: "v0.16.0"
    hooks:
      - id: terraform-docs-go
        args: ["markdown", "table", "--output-file", "README.md", "./"]
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: "v1.74.1"
    hooks:
      - id: terraform_checkov
      - id: terraform_fmt
      - id: terraform_providers_lock
      - id: terraform_tflint
      - id: terraform_tfsec
      - id: terraform_validate
```

<h4> Repository: terraform-docs </h4>

```hcl
- repo: https://github.com/terraform-docs/terraform-docs
  rev: "v0.16.0"
  hooks:
    - id: terraform-docs-go
      args: ["markdown", "table", "--output-file", "README.md", "./"]
```
- This configuration sets up the terraform-docs tool to generate documentation for your Terraform modules.
- Specifies the repository URL for terraform-docs.
- Specifies the version of terraform-docs to use (v0.16.0).
- terraform-docs-go is the hook that runs terraform-docs.
- The arguments specify that the output format should be Markdown in a table format, and the output should be saved 
  to README.md.

<h4>Repository: pre-commit-terraform</h4>

```hcl
- repo: https://github.com/antonbabenko/pre-commit-terraform
  rev: "v1.74.1"
  hooks:
    - id: terraform_checkov
    - id: terraform_fmt
    - id: terraform_providers_lock
    - id: terraform_tflint
    - id: terraform_tfsec
    - id: terraform_validate
```
- This configuration sets up various pre-commit hooks from the pre-commit-terraform repository to enforce Terraform code quality and security.
- Specifies the repository URL for pre-commit-terraform.
- Specifies the version of pre-commit-terraform to use (v1.74.1).
Hooks:
- terraform_checkov: Runs Checkov to perform static analysis of Terraform code for security and best practices.
- terraform_fmt: Ensures that Terraform files are formatted according to the standard.
- terraform_providers_lock: Locks Terraform provider dependencies.
- terraform_tflint: Runs TFLint to detect errors and enforce best practices in Terraform code.
- terraform_tfsec: Runs TFSec to perform static analysis of Terraform code for security issues.
- terraform_validate: Runs terraform validate to ensure the configuration is syntactically valid and internally 
  consistent.
