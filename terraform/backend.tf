terraform {
  backend "s3" {
   bucket = "sctp-core-tfstate"
   key    = "ecs-cicd-jaz.tfstate"
   region = "ap-southeast-1"
  }
}