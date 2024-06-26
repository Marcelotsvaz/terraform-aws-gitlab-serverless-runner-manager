# 
# GitLab Serverless Runner Manager
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Worker instance.
#-------------------------------------------------------------------------------
resource aws_launch_template main {
	for_each = var.runners
	
	name = "${var.prefix}-${var.identifier}-launchTemplate-${each.key}"
	update_default_version = true
	
	image_id = data.aws_ami.main.id
	vpc_security_group_ids = [ aws_default_security_group.main.id ]
	iam_instance_profile { arn = aws_iam_instance_profile.main.arn }
	user_data = module.user_data[each.key].content_base64
	ebs_optimized = true
	
	instance_requirements {
		vcpu_count { min = each.value.min_vcpu }
		memory_mib { min = each.value.min_memory_mib }
		allowed_instance_types = data.aws_ec2_instance_types.main.instance_types
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
		tags = merge( { Name = "${var.name} Spot Request" }, data.aws_default_tags.main.tags )
	}
	
	tag_specifications {
		resource_type = "instance"
		tags = merge( { Name = var.name }, data.aws_default_tags.main.tags )
	}
	
	tag_specifications {
		resource_type = "volume"
		tags = merge( { Name = "${var.name} Root Volume" }, data.aws_default_tags.main.tags )
	}
	
	tags = {
		Name = "${var.name} Launch Template"
	}
}


module user_data {
	source = "gitlab.com/vaz-projects/user-data/external"
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
		docker_privileged = each.value.docker_privileged
		cache_bucket = aws_s3_bucket.main.id
		cache_prefix = local.bucket_prefix
	}
	
	environment = {
		hostname = "gitlab-runner"
	}
}


data aws_ec2_instance_types main {
	filter {
		name = "supported-boot-mode"
		values = [ "uefi" ]
	}
	
	filter {
		name = "supported-usage-class"
		values = [ "spot" ]
	}
	
	filter {
		name = "processor-info.supported-architecture"
		values = [ "x86_64" ]
	}
}


data aws_ami main {
	most_recent = true
	owners = [ "self" ]
	
	filter {
		name = "name"
		values = [ "VAZ Projects Builder AMI" ]
	}
}


data aws_default_tags main {}



# 
# Instance profile.
#-------------------------------------------------------------------------------
resource aws_iam_instance_profile main {
	name = "${var.prefix}-${var.identifier}-instanceProfile"
	role = aws_iam_role.instance.name
	
	tags = {
		Name = "${var.name} Instance Profile"
	}
}


resource aws_iam_role instance {
	name = "${var.prefix}-${var.identifier}-role"
	assume_role_policy = data.aws_iam_policy_document.instance_assume_role.json
	managed_policy_arns = []
	
	inline_policy {
		name = "${var.prefix}-${var.identifier}-rolePolicy"
		
		policy = data.aws_iam_policy_document.instance_role.json
	}
	
	tags = {
		Name = "${var.name} Role"
	}
}


data aws_iam_policy_document instance_assume_role {
	statement {
		sid = "ec2AssumeRole"
		actions = [ "sts:AssumeRole" ]
		principals {
			type = "Service"
			identifiers = [ "ec2.amazonaws.com" ]
		}
	}
}


data aws_iam_policy_document instance_role {
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