terraform {
  backend "s3" {
    bucket = "andre-lab-tf-state-695385418380-us-east-1-an"
    key    = "terraform-fargate.tfstate"
    region = "us-east-1"
  }
}
