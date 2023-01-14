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
	
	source_dir = "${path.module}/files/src"
	handler = "jobRequester.main"
	environment = {
		webhookToken = random_password.webhook_token.result
		# runnerToken = gitlab_runner.main.authentication_token
		gitlabUrl = "https://gitlab.com"
		jobsTableName = aws_dynamodb_table.jobs.name
		# workersTableName = aws_dynamodb_table.workers.name
		# launchTemplateId = aws_launch_template.main.id
		# launchTemplateVersion = aws_launch_template.main.latest_version
		subnetIds = join( " ", aws_subnet.main[*].id )
	}
	
	policies = [ data.aws_iam_policy_document.job_requester ]
	
	create_url = true
}


data "aws_iam_policy_document" "job_requester" {
	# Used in jobRequester.py.
	statement {
		sid = "dynamodbPutItem"
		
		actions = [ "dynamodb:PutItem" ]
		
		resources = [
			aws_dynamodb_table.jobs.arn,
			# aws_dynamodb_table.workers.arn,
		]
	}
	
	statement {
		sid = "ec2CreateWorker"
		
		actions = [
			"ec2:CreateFleet",
			"ec2:RunInstances",
			"ec2:CreateTags",
		]
		
		resources = [ "*" ]
	}
	
	statement {
		sid = "iamPassRole"
		
		actions = [ "iam:PassRole" ]
		
		resources = [ aws_iam_role.instance.arn ]
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
	
	source_dir = "${path.module}/files/src"
	handler = "jobProvider.main"
	environment = {
		# runnerToken = gitlab_runner.main.authentication_token
		jobsTableName = aws_dynamodb_table.jobs.name
		# workersTableName = aws_dynamodb_table.workers.name
	}
	
	policies = [ data.aws_iam_policy_document.job_provider ]
}


data "aws_iam_policy_document" "job_provider" {
	# Used in jobProvider.py.
	statement {
		sid = "dynamodbGetItem"
		
		actions = [
			"dynamodb:Scan",
			"dynamodb:DeleteItem",
		]
		
		resources = [
			aws_dynamodb_table.jobs.arn,
			# aws_dynamodb_table.workers.arn,
		]
	}
	
	statement {
		sid = "ec2TerminateInstances"
		
		actions = [ "ec2:TerminateInstances" ]
		
		resources = [ "*" ]
	}
}


resource "aws_lambda_permission" "job_provider" {
	function_name = module.job_provider.function_name
	statement_id = "lambdaInvokeFunction"
	principal = "apigateway.amazonaws.com"
	action = "lambda:InvokeFunction"
	source_arn = "${aws_apigatewayv2_stage.main.execution_arn}/${replace( aws_apigatewayv2_route.job_provider.route_key, " ", "")}"
}



# 
# Authorizer.
#-------------------------------------------------------------------------------
module "authorizer" {
	source = "./module/lambda"
	
	name = "Authorizer"
	identifier = "authorizer"
	prefix = "${var.prefix}-${var.identifier}"
	
	source_dir = "${path.module}/files/src"
	handler = "authorizer.main"
	environment = {
		token = random_password.webhook_token.result
	}
}


resource "aws_lambda_permission" "authorizer" {
	function_name = module.authorizer.function_name
	statement_id = "lambdaInvokeFunction"
	principal = "apigateway.amazonaws.com"
	action = "lambda:InvokeFunction"
	source_arn = "${aws_apigatewayv2_api.main.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.main.id}"
}



# 
# Job database.
#-------------------------------------------------------------------------------
resource "aws_dynamodb_table" "jobs" {
	name = "jobs"
	hash_key = "workerId"
	
	billing_mode = "PAY_PER_REQUEST"
	
	attribute {
		name = "workerId"
		type = "S"
	}
	
	tags = {
		Name = "${var.name} Job Database"
	}
}


# resource "aws_dynamodb_table" "workers" {
# 	name = "workers"
# 	hash_key = "id"
	
# 	billing_mode = "PAY_PER_REQUEST"
	
# 	attribute {
# 		name = "id"
# 		type = "N"
# 	}
	
# 	tags = {
# 		Name = "${var.name} Worker Database"
# 	}
# }