# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Lambda Function.
#-------------------------------------------------------------------------------
resource "aws_lambda_function" "main" {
	function_name = local.lambda_function_name
	role = aws_iam_role.main.arn
	
	runtime = "python3.9"
	filename = data.archive_file.lambda_module.output_path
	source_code_hash = data.archive_file.lambda_module.output_base64sha256
	handler = var.handler
	timeout = var.timeout
	
	environment {
		variables = merge( var.environment, {
			PYTHONPATH = "env/lib/python3.10/site-packages"
		} )
	}
	
	# Make sure the log group is created before the function because we removed the implicit dependency.
	depends_on = [ aws_cloudwatch_log_group.main ]
	
	tags = {
		Name = "${var.name} Lambda"
	}
}


data "archive_file" "lambda_module" {
	type = "zip"
	source_dir = var.source_dir
	output_path = "/tmp/terraform/${var.prefix}/${var.identifier}/module.zip"
	excludes = [ "env/lib64" ]	# lib64 is a symlink which isn't supported by archive_file.
}


resource "aws_lambda_function_url" "main" {
	count = var.create_url ? 1 : 0
	
	function_name = aws_lambda_function.main.function_name
	authorization_type = "NONE"
}



# 
# CloudWatch.
#-------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "main" {
	name = "/aws/lambda/${local.lambda_function_name}"
	
	tags = {
		Name = "${var.name} Lambda Log Group"
	}
}



# 
# Lambda IAM Role.
#-------------------------------------------------------------------------------
resource "aws_iam_role" "main" {
	name = "${var.prefix}-${var.identifier}-lambdaRole"
	assume_role_policy = data.aws_iam_policy_document.assume_role.json
	managed_policy_arns = []
	
	inline_policy {
		name = "${var.prefix}-${var.identifier}-lambdaRoleLogsPolicy"
		
		policy = data.aws_iam_policy_document.write_logs.json
	}
	
	dynamic "inline_policy" {
		for_each = var.policies
		
		content {
			name = "${var.prefix}-${var.identifier}-lambdaRolePolicy"
			
			policy = inline_policy.value.json
		}
	}
	
	tags = {
		Name: "${var.name} Lambda Role"
	}
}


data "aws_iam_policy_document" "assume_role" {
	statement {
		sid = "lambdaAssumeRole"
		
		principals {
			type = "Service"
			identifiers = [ "lambda.amazonaws.com" ]
		}
		
		actions = [ "sts:AssumeRole" ]
	}
}


data "aws_iam_policy_document" "write_logs" {
	# Used by Lambda.
	statement {
		sid = "cloudwatchWriteLogs"
		
		actions = [
			"logs:CreateLogStream",
			"logs:PutLogEvents",
		]
		
		resources = [ "${aws_cloudwatch_log_group.main.arn}:*" ]
	}
}