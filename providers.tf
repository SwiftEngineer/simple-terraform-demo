provider "aws" {
  access_key = "${var.aws_secret_key_id}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}