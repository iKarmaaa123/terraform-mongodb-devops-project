// Create a Project
resource "mongodbatlas_project" "atlas-project" {
  org_id = var.atlas_org_id
  name   = var.atlas_project_name
}

// Create a Database User
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

// Create a Database Password
resource "random_password" "db-user-password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

// Create Database IP Access List
resource "mongodbatlas_project_ip_access_list" "ip" {
project_id = mongodbatlas_project.atlas-project.id
ip_address = var.ip_address  
}

// Create an Atlas Advanced Cluster
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