provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Techtest = "true"
      Candidate = var.candidate
    }
  } 
}


