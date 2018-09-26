variable "aws_region" {
  description = "AWS region to launch service in."
  default     = "us-west-2"
}

variable "aws_secret_key_id" {
  description = "AWS secret key ID"
}

variable "aws_secret_key" {
  description = "AWS secret key"
}

variable "ui_bucket_name" {
  description = "name of the bucket"
  default = "terraform-demo-ui"
}