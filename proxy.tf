# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# API Gateway.
#-------------------------------------------------------------------------------
resource "aws_apigatewayv2_api" "main" {
	name = "api"
	protocol_type = "HTTP"
	
	tags = {
		Name = "${var.name} API Gateway"
	}
}


resource "aws_apigatewayv2_stage" "main" {
	api_id = aws_apigatewayv2_api.main.id
	name = "$default"
	auto_deploy = true
	
	tags = {
		Name = "${var.name} API Gateway Stage"
	}
}


# 
# GitLab Proxy.
#-------------------------------------------------------------------------------
resource "aws_apigatewayv2_route" "gitlab" {
	api_id = aws_apigatewayv2_api.main.id
	route_key = "$default"
	target = "integrations/${aws_apigatewayv2_integration.gitlab.id}"
}


resource "aws_apigatewayv2_integration" "gitlab" {
	api_id = aws_apigatewayv2_api.main.id
	integration_type = "HTTP_PROXY"
	integration_method = "ANY"
	integration_uri = "https://gitlab.com"
}


# 
# Lambda Route.
#-------------------------------------------------------------------------------
# resource "aws_apigatewayv2_route" "lambda" {
# 	api_id = aws_apigatewayv2_api.main.id
# 	route_key = "POST /api/v4/jobs/request"
# 	target = "integrations/${aws_apigatewayv2_integration.lambda.id}"
# }


# resource "aws_apigatewayv2_integration" "lambda" {
# 	api_id = aws_apigatewayv2_api.main.id
# 	integration_type = "AWS_PROXY"
# 	integration_method = "POST"
# 	integration_uri = aws_lambda_function.example.invoke_arn
# }