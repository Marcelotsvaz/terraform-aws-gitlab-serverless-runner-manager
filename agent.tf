# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



module "provisioner" {
	source = "./module/lambda"
	
	name = "Provisioner"
	identifier = "provisioner"
	prefix = "${var.prefix}-${var.identifier}"
	
	source_file = "${path.module}/files/provisioner.py"
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