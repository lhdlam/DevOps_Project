terraform {
  backend "s3" {
    bucket = "jenkins-dev1-terraform-state-backend"
    key = "jenkins/statefile"
    region = "us-east-1"
  }
}  
