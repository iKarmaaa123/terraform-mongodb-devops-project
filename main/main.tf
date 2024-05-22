// module for mongodb atlas cluster
module "cluster" {
    source = "../modules/cluster"
}

// module for aws vpc
module "vpc" {
  source = "../modules/vpc"
}

// peering resource for mongodb atlas cluster and aws vpc
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

// resource for mongodbatlas network container
resource "mongodbatlas_network_container" "test" {
  project_id       = module.cluster.mongodb_atlas_project_id
  atlas_cidr_block = module.cluster.mongodb_atlas_cidr_block
  provider_name    = "AWS"
  region_name      = "US_EAST_1"
}

// resource for aws vpc peering connection accepter
resource "aws_vpc_peering_connection_accepter" "peering_accept" {
  vpc_peering_connection_id = mongodbatlas_network_peering.peering.connection_id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

// resource for aws route to mongodb atlas cluster
resource "aws_route" "to_mongodb_atlas" {
  route_table_id            = module.vpc.route_table_id
  destination_cidr_block    = mongodbatlas_network_peering.peering.atlas_cidr_block
  vpc_peering_connection_id = mongodbatlas_network_peering.peering.connection_id
}