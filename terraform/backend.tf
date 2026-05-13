terraform {
  backend "s3" {
    bucket = "sctp-core-tfstate"
    key    = "jaz-microservice-ecs-demo.tfstate"
    region = "ap-southeast-1"
  }
}