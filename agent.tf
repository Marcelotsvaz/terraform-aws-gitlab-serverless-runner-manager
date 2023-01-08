# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Job requester.
#-------------------------------------------------------------------------------
module "jobRequester" {
	source = "./module/lambda"
	
	name = "Job Requester"
	identifier = "jobRequester"
	prefix = "${var.prefix}-${var.identifier}"
	
	source_dir = "${path.module}/files/jobRequester/packages"
	handler = "jobRequester.main"
	timeout = 10
	
	# role_policy = data.aws_iam_policy_document.load_balancer_policy
	
	environment = {
		runnerToken = gitlab_runner.main.authentication_token
		gitlabUrl = "https://gitlab.com"
	}
}


# data "aws_iam_policy_document" "agent_role" {
# 	# Used in lambda.py.
# 	statement {
# 		sid = "ec2ModifySpotFleetRequest"
		
# 		actions = [ "ec2:ModifySpotFleetRequest" ]
		
# 		resources = [ "arn:aws:ec2:${data.aws_arn.main.region}:${data.aws_arn.main.account}:spot-fleet-request/${aws_spot_fleet_request.main.id}" ]
# 	}
# }



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
	
	# role_policy = data.aws_iam_policy_document.load_balancer_policy
	
	environment = {
		foo = "bar"
	}
}


# data "aws_iam_policy_document" "agent_role" {
# 	# Used in lambda.py.
# 	statement {
# 		sid = "ec2ModifySpotFleetRequest"
		
# 		actions = [ "ec2:ModifySpotFleetRequest" ]
		
# 		resources = [ "arn:aws:ec2:${data.aws_arn.main.region}:${data.aws_arn.main.account}:spot-fleet-request/${aws_spot_fleet_request.main.id}" ]
# 	}
# }