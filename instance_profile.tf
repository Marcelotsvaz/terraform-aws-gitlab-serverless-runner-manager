# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



resource "aws_iam_instance_profile" "main" {
	name = "${var.prefix}-${var.identifier}-instanceProfile"
	role = aws_iam_role.instance.name
	
	tags = {
		Name: "${var.name} Instance Profile"
	}
}


resource "aws_iam_role" "instance" {
	name = "${var.prefix}-${var.identifier}-role"
	assume_role_policy = data.aws_iam_policy_document.instance_assume_role.json
	managed_policy_arns = []
	
	inline_policy {
		name = "${var.prefix}-${var.identifier}-rolePolicy"
		
		policy = data.aws_iam_policy_document.instance_role.json
	}
	
	tags = {
		Name: "${var.name} Role"
	}
}


data "aws_iam_policy_document" "instance_assume_role" {
	statement {
		sid = "ec2AssumeRole"
		
		principals {
			type = "Service"
			identifiers = [ "ec2.amazonaws.com" ]
		}
		
		actions = [ "sts:AssumeRole" ]
	}
}


data "aws_iam_policy_document" "instance_role" {
	statement {
		sid = "s3WriteRunnerCache"
		
		actions = [
			"s3:GetObject",
			"s3:GetObjectVersion",
			"s3:PutObject",
			"s3:DeleteObject",
		]
		
		resources = [ "${aws_s3_bucket.main.arn}/${local.bucket_prefix}/*" ]
	}
}