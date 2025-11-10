output "apigw_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "apigw_invoke_url" {
  value = "${aws_api_gateway_rest_api.this.execution_arn}"
}

output "apigw_endpoint" {
  value = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.environment}.amazonaws.com/${var.apigw_stage_name}"
}
