terraform {
  backend "s3" {
    bucket = "devops-terraform-statefile"
    key = "devops/statefile"
    region = "us-east-1"
  }
}  
