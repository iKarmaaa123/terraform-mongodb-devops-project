// output for mongodb atlas project id
output "mongodb_atlas_project_id" {
    value = mongodbatlas_project.atlas-project.id
}

// output for mongodb atlas cidr block
output "mongodb_atlas_cidr_block" {
    value = "192.168.0.0/21"
}

// output for mongodb atlas region
output "region_name" {
    value = "US_EAST_1"
}

// output for project name
output "project_name" {
  value = "terraformProject"
}

// output for organisation id
output "organisation_id" {
  value = "65e24d75b0bbab5dbe0ebe25"
}