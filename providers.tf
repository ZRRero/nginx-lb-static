provider "aws" {
  alias = "master_region"

  default_tags {
    tags = {
      Author = "David Useche"
      Type = "nginx-lb-static"
    }
  }
}