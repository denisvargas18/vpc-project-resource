//terraform {
//    required_version = ">= 0.15"
//}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27" #aws version into terraform, local using v3.51.0
    }
  }
  required_version = ">= 0.14.9" #version terraform, local using v1.0.2
}