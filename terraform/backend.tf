terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "terraformstates-bucket"
    key = "github-actions-dev/state.tfstate"
    region = "ap-south-1"
  } 
}