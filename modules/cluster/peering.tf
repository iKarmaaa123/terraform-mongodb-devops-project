resource "mongodbatlas_network_peering" "peering" {
  project_id             = mongodbatlas_project.atlas-project.id
  atlas_cidr_block       = var.atlas_cidr_block
  container_id           = mongodbatlas_network_container.test.id
  accepter_region_name   = var.acceptor_region_name
  provider_name          = var.provider_name
  route_table_cidr_block = aws_vpc.my_vpc.cidr_block
  vpc_id                 = aws_vpc.my_vpc.id
  aws_account_id         = var.aws_account_id
}

resource "mongodbatlas_network_container" "test" {
  project_id       = mongodbatlas_project.atlas-project.id
  atlas_cidr_block = var.atlas_cidr_block
  provider_name    = var.provider_name
  region_name      = var.atlas_region
}

resource "aws_vpc_peering_connection_accepter" "peering_accept" {
  vpc_peering_connection_id = mongodbatlas_network_peering.peering.connection_id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

resource "aws_route" "to_mongodb_atlas" {
  route_table_id            = aws_route_table.my_route_table.id
  destination_cidr_block    = mongodbatlas_network_peering.peering.atlas_cidr_block
  vpc_peering_connection_id = mongodbatlas_network_peering.peering.connection_id
}