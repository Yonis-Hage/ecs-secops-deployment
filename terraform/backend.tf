terraform {
  backend "s3" {
    bucket         = "tf-backend-threatcomposer-xyz123"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "tf-backend"
    encrypt        = true
  }
}
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
