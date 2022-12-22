# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



locals {
	lambda_function_name = "${var.prefix}-${var.identifier}-lambda"	# Avoid cyclic dependency.
}



# 
# Lambda Function.
#-------------------------------------------------------------------------------
resource "aws_lambda_function" "lambda" {
	function_name = local.lambda_function_name
	role = aws_iam_role.lambda_role.arn
	
	runtime = "python3.9"
	filename = data.archive_file.lambda.output_path
	source_code_hash = data.archive_file.lambda.output_base64sha256
	handler = "lambda.main"
	timeout = 10
	# reserved_concurrent_executions = 1
	
	environment {
		variables = {
			secretToken = random_password.webhook_token.result
			spotFleetId = aws_spot_fleet_request.fleet.id
		}
	}
	
	# Make sure the log group is created before the function because we removed the implicit dependency.
	depends_on = [ aws_cloudwatch_log_group.lambda_log_group ]
	
	tags = {
		Name = "${var.name} Lambda"
	}
}


data "archive_file" "lambda" {
	type = "zip"
	source_file = "${path.module}/lambda.py"
	output_path = "deployment/${var.prefix}/${var.identifier}/lambda.zip"
}


resource "aws_lambda_function_url" "lambda_url" {
	function_name = aws_lambda_function.lambda.function_name
	authorization_type = "NONE"
}


resource "aws_cloudwatch_log_group" "lambda_log_group" {
	name = "/aws/lambda/${local.lambda_function_name}"
	
	tags = {
		Name = "${var.name} Lambda Log Group"
	}
}



# 
# Lambda IAM Role.
#-------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_role" {
	name = "${var.prefix}-${var.identifier}-lambdaRole"
	assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
	
	inline_policy {
		name = "${var.prefix}-${var.identifier}-lambdaRolePolicy"
		
		policy = data.aws_iam_policy_document.lambda_role_policy.json
	}
	
	tags = {
		Name: "${var.name} Lambda Role"
	}
}


data "aws_iam_policy_document" "lambda_assume_role_policy" {
	statement {
		sid = "lambdaAssumeRole"
		
		principals {
			type = "Service"
			identifiers = [ "lambda.amazonaws.com" ]
		}
		
		actions = [ "sts:AssumeRole" ]
	}
}


data "aws_iam_policy_document" "lambda_role_policy" {
	# Used in lambda.py.
	statement {
		sid = "ec2ModifySpotFleetRequest"
		
		actions = [ "ec2:ModifySpotFleetRequest" ]
		
		resources = [ "arn:aws:ec2:${data.aws_arn.arn.region}:${data.aws_arn.arn.account}:spot-fleet-request/${aws_spot_fleet_request.fleet.id}" ]
	}
	
	# Used by Lambda.
	statement {
		sid = "cloudwatchWriteLogs"
		
		actions = [
			"logs:CreateLogStream",
			"logs:PutLogEvents",
		]
		
		resources = [ "${aws_cloudwatch_log_group.lambda_log_group.arn}:*" ]
	}
}


data "aws_arn" "arn" {
	# Get region and account ID to construct Spot Fleet ARN.
	arn = aws_launch_template.launch_template.arn
}