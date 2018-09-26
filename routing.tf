# certificate

variable "acm_cert_arn" {
  description = "domain that should match the domain of an ISSUED cert of AWS ACM"
}

variable "api_domain_name" {
  description = "if your domain for your cert is something like `*.yolo.com`, then make this entry `yolo.com`"
}

variable "hosted_zone_id" {
  description = "id of the hosted zone to place the cloudfront route53 alias in"
}

# Routing for api

resource "aws_route53_record" "api_cloudfront_alias" {
  zone_id = "${var.hosted_zone_id}"

  name = "${aws_api_gateway_domain_name.api_domain.domain_name}"
  type = "A"

  alias = {
    name                   = "${aws_api_gateway_domain_name.api_domain.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.api_domain.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_api_gateway_domain_name" "api_domain" {
  domain_name = "${var.bucket_name}.${var.api_domain_name}"
  certificate_arn = "${var.acm_cert_arn}"
}

resource "aws_api_gateway_base_path_mapping" "path_mapping" {
  api_id      = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "${aws_api_gateway_deployment.api_gateway_deployment.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.api_domain.domain_name}"

  base_path = "live"
}