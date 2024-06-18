terraform {
  backend "s3" {
    bucket = "devops-project-terraform-state-backend"
    key = "devops/statefile"
    region = "us-east-1"
  }
}  
