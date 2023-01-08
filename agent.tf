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