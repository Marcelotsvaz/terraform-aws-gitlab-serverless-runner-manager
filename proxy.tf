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


resource "aws_apigatewayv2_authorizer" "main" {
	api_id = aws_apigatewayv2_api.main.id
	name = "lambdaAuthorizer"
	authorizer_type = "REQUEST"
	authorizer_uri = module.authorizer.invoke_arn
	authorizer_payload_format_version = "2.0"
	enable_simple_responses = true
	
	identity_sources = [ "$request.header.x-gitlab-token" ]
}



# 
# Webhook Handler Route.
#-------------------------------------------------------------------------------
resource "aws_apigatewayv2_route" "webhook_handler" {
	api_id = aws_apigatewayv2_api.main.id
	route_key = "POST /manager"
	authorization_type = "CUSTOM"
	authorizer_id = aws_apigatewayv2_authorizer.main.id
	target = "integrations/${aws_apigatewayv2_integration.webhook_handler.id}"
}


resource "aws_apigatewayv2_integration" "webhook_handler" {
	api_id = aws_apigatewayv2_api.main.id
	integration_type = "AWS_PROXY"
	integration_method = "POST"
	integration_uri = module.webhook_handler.invoke_arn
}



# 
# Job Provider Route.
#-------------------------------------------------------------------------------
resource "aws_apigatewayv2_route" "job_provider" {
	api_id = aws_apigatewayv2_api.main.id
	route_key = "POST /{workerId}/api/v4/jobs/request"
	# authorization_type = "CUSTOM"
	# authorizer_id = aws_apigatewayv2_authorizer.main.id
	target = "integrations/${aws_apigatewayv2_integration.job_provider.id}"
}


resource "aws_apigatewayv2_integration" "job_provider" {
	api_id = aws_apigatewayv2_api.main.id
	integration_type = "AWS_PROXY"
	integration_method = "POST"
	integration_uri = module.job_provider.invoke_arn
}



# 
# GitLab Proxy Route.
#-------------------------------------------------------------------------------
resource "aws_apigatewayv2_route" "gitlab" {
	api_id = aws_apigatewayv2_api.main.id
	route_key = "ANY /{workerId}/{path+}"
	# authorization_type = "CUSTOM"
	# authorizer_id = aws_apigatewayv2_authorizer.main.id
	target = "integrations/${aws_apigatewayv2_integration.gitlab.id}"
}


resource "aws_apigatewayv2_integration" "gitlab" {
	api_id = aws_apigatewayv2_api.main.id
	integration_type = "HTTP_PROXY"
	integration_method = "ANY"
	integration_uri = "https://gitlab.com/{path}"
}