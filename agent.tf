# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Job requester.
#-------------------------------------------------------------------------------
module "job_requester" {
	source = "./module/lambda"
	
	name = "Job Requester"
	identifier = "jobRequester"
	prefix = "${var.prefix}-${var.identifier}"
	
	source_dir = "${path.module}/files/jobRequester/packages"
	handler = "jobRequester.main"
	timeout = 10
	
	policies = [ data.aws_iam_policy_document.job_requester ]
	
	environment = {
		webhookToken = random_password.webhook_token.result
		runnerToken = gitlab_runner.main.authentication_token
		gitlabUrl = "https://gitlab.com"
		jobsTableName = aws_dynamodb_table.main.name
	}
}


data "aws_iam_policy_document" "job_requester" {
	# Used in jobRequester.py.
	statement {
		sid = "dynamodbPutItem"
		
		actions = [ "dynamodb:PutItem" ]
		
		resources = [ aws_dynamodb_table.main.arn ]
	}
}


resource "aws_lambda_function_url" "job_requester" {
	function_name = module.job_requester.function_name
	authorization_type = "NONE"
}



# 
# Executor Provisioner.
#-------------------------------------------------------------------------------
module "provisioner" {
	source = "./module/lambda"
	
	name = "Provisioner"
	identifier = "provisioner"
	prefix = "${var.prefix}-${var.identifier}"
	
	source_dir = "${path.module}/files/provisioner"
	handler = "provisioner.main"
	timeout = 10
	
	environment = {
		foo = "bar"
	}
}



# 
# Job provider.
#-------------------------------------------------------------------------------
module "job_provider" {
	source = "./module/lambda"
	
	name = "Job Provider"
	identifier = "jobProvider"
	prefix = "${var.prefix}-${var.identifier}"
	
	source_dir = "${path.module}/files/jobProvider"
	handler = "jobProvider.main"
	timeout = 10
	
	policies = [ data.aws_iam_policy_document.job_provider ]
	
	environment = {
		runnerToken = gitlab_runner.main.authentication_token
		jobsTableName = aws_dynamodb_table.main.name
	}
}


data "aws_iam_policy_document" "job_provider" {
	# Used in jobProvider.py.
	statement {
		sid = "dynamodbGetItem"
		
		actions = [
			"dynamodb:Scan",
			"dynamodb:DeleteItem",
		]
		
		resources = [ aws_dynamodb_table.main.arn ]
	}
}


resource "aws_lambda_permission" "autoscaling_lambda_resource_policy" {
	function_name = module.job_provider.function_name
	statement_id = "lambdaInvokeFunction"
	principal = "apigateway.amazonaws.com"
	action = "lambda:InvokeFunction"
	source_arn = "${aws_apigatewayv2_stage.main.execution_arn}/${replace( aws_apigatewayv2_route.lambda.route_key, " ", "")}"
}




# 
# Job database.
#-------------------------------------------------------------------------------
resource "aws_dynamodb_table" "main" {
	name = "jobs"
	hash_key = "id"
	
	billing_mode = "PAY_PER_REQUEST"
	
	attribute {
		name = "id"
		type = "N"
	}
	
	tags = {
		Name = "${var.name} Job Database"
	}
}