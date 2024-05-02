// Configure the MongoDB Atlas Provider 
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "~> 1.15.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "terraform-mongodb-project"
    key    = "statefile/terraform.tfstate"
    region = "us-east-1"
  }
}


//fmdskfksnfknknfksdnfksnknsndnfnfnsfnsjfn
