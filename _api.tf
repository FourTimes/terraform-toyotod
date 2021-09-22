resource "aws_api_gateway_rest_api" "getTranslation" {
  api_key_source               = "HEADER"
  description                  = "API to trigger from ECS"
  disable_execute_api_endpoint = false
  minimum_compression_size     = -1
  name                         = var.api_name
  tags                         = merge({ Name = var.api_name }, tomap(var.additional_tags))
  endpoint_configuration {
    types = [
      "REGIONAL",
    ]
  }
}
