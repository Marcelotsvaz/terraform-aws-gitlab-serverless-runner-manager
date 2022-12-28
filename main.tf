# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Runner instance.
#-------------------------------------------------------------------------------
resource "aws_spot_fleet_request" "main" {
	target_capacity = 0
	instance_interruption_behaviour = "stop"
	terminate_instances_on_delete = true
	iam_fleet_role = "arn:aws:iam::983585628015:role/aws-ec2-spot-fleet-tagging-role"	# TODO
	
	launch_template_config {
		launch_template_specification {
			id = aws_launch_template.main.id
			version = aws_launch_template.main.latest_version
		}
	}
	
	tags = {
		Name = "${var.name} Spot Fleet Request"
	}
}


resource "aws_launch_template" "main" {
	name = "${var.prefix}-${var.identifier}-launchTemplate"
	update_default_version = true
	
	image_id = data.aws_ami.main.id
	instance_type = "t3a.medium"
	iam_instance_profile { arn = aws_iam_instance_profile.main.arn }
	user_data = module.user_data.content_base64
	ebs_optimized = true
	
	block_device_mappings {
		device_name = "/dev/xvda"
		
		ebs {
			volume_size = 10
			encrypted = true
		}
	}
	
	network_interfaces {
		subnet_id = var.subnet_id
		ipv6_address_count = 1
		security_groups = var.vpc_security_group_ids
	}
	
	tag_specifications {
		resource_type = "spot-instances-request"
		tags = merge( { Name = "${var.name} Spot Request" }, var.default_tags )
	}
	
	tag_specifications {
		resource_type = "instance"
		tags = merge( { Name = var.name }, var.default_tags )
	}
	
	tag_specifications {
		resource_type = "volume"
		tags = merge( { Name = "${var.name} Root Volume" }, var.default_tags )
	}
	
	tags = {
		Name = "${var.name} Launch Template"
	}
}


module "user_data" {
	source = "gitlab.com/marcelotsvaz/user-data/external"
	version = "~> 1.0"
	
	input_dir = "${path.module}/files"
	
	files = [ "perInstance.sh" ]
	templates = [ "config.toml.tftpl" ]
	
	context = {
		runner_name = var.name
		runner_id = gitlab_runner.main.id
		runner_authentication_token = gitlab_runner.main.authentication_token
		cache_bucket_region = aws_s3_bucket.main.region
		cache_bucket = aws_s3_bucket.main.id
		cache_prefix = local.bucket_prefix
	}
	
	environment = {
		hostname = "gitlab-runner"
		ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH7gGmj7aRlkjoPKKM35M+dG6gMkgD9IEZl2UVp6JYPs VAZ Projects SSH Key"
	}
}


data "aws_ami" "main" {
	most_recent = true
	owners = [ "self" ]
	
	filter {
		name = "name"
		values = [ "VAZ Projects Builder AMI" ]
	}
}



# 
# Instance profile.
#-------------------------------------------------------------------------------
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