# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Worker instance.
#-------------------------------------------------------------------------------
resource "aws_launch_template" "main" {
	for_each = var.runners
	
	name = "${var.prefix}-${var.identifier}-launchTemplate-${each.key}"
	update_default_version = true
	
	image_id = data.aws_ami.main.id
	vpc_security_group_ids = [ aws_default_security_group.main.id ]
	iam_instance_profile { arn = aws_iam_instance_profile.main.arn }
	user_data = module.user_data[each.key].content_base64
	ebs_optimized = true
	
	instance_requirements {
		vcpu_count {
			min = each.value.min_vcpu
			max = 8
		}
		memory_mib {
			min = each.value.min_memory_mib
			max = 16384
		}
		instance_generations = [ "current" ]
		excluded_instance_types = [
			"i3.*",
			"m4.*",
			"c4.*",
			"r4.*",
		]
	}
	
	block_device_mappings {
		device_name = "/dev/xvda"
		
		ebs {
			volume_size = 10
			encrypted = true
		}
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
	version = "~> 1.0.1"
	
	for_each = var.runners
	
	input_dir = "${path.module}/files"
	
	files = [ "perInstance.sh" ]
	templates = [ "config.toml.tftpl" ]
	
	context = {
		runner_name = each.key
		runner_id = gitlab_runner.main[each.key].id
		runner_authentication_token = gitlab_runner.main[each.key].authentication_token
		proxy_url = aws_apigatewayv2_api.main.api_endpoint
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
		sid = "putRunnerCache"
		
		actions = [
			"s3:GetObject",
			"s3:GetObjectVersion",
			"s3:PutObject",
			"s3:DeleteObject",
		]
		
		resources = [ "${aws_s3_bucket.main.arn}/${local.bucket_prefix}/*" ]
	}
}