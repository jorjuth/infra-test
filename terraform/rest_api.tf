
resource "aws_api_gateway_vpc_link" "this" {
  name        = var.project_name
  target_arns = [aws_lb.nlb.id]
}

resource "aws_api_gateway_rest_api" "this" {
  name        = var.project_name
  description = "Member API ${terraform.workspace}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(
    var.common_tags,
    {
      Environment = terraform.workspace
    }
  )
}

/*
resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  #path_part   = "{proxy+}"
  path_part = "/"
}
*/

resource "aws_api_gateway_method" "this" {
  for_each = toset(["POST", "GET"])

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_rest_api.this.root_resource_id
  http_method   = each.key
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this" {
  for_each = {
    "POST" = {
      uri = "http://${aws_lb.nlb.dns_name}:${var.app_port}/"
    },
    "GET" = {
      uri = "http://${aws_lb.nlb.dns_name}:${var.app_port}/"
    }
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  #resource_id             = aws_api_gateway_resource.this.id
  resource_id             = aws_api_gateway_rest_api.this.root_resource_id
  http_method             = aws_api_gateway_method.this[each.key].http_method
  integration_http_method = each.key
  type                    = "HTTP"
  uri                     = each.value.uri
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
}
