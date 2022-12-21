# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



resource "aws_spot_fleet_request" "fleet" {
	target_capacity = 0
	instance_interruption_behaviour = "stop"
	terminate_instances_on_delete = true
	iam_fleet_role = "arn:aws:iam::983585628015:role/aws-ec2-spot-fleet-tagging-role"	# TODO
	
	launch_template_config {
		launch_template_specification {
			id = aws_launch_template.launch_template.id
			version = aws_launch_template.launch_template.latest_version
		}
	}
	
	tags = {
		Name = "${var.name} Spot Fleet Request"
	}
}


resource "aws_launch_template" "launch_template" {
	name = "${var.prefix}-${var.identifier}-launchTemplate"
	update_default_version = true
	
	image_id = data.aws_ami.ami.id
	instance_type = "t3a.medium"
	iam_instance_profile { arn = aws_iam_instance_profile.instance_profile.arn }
	user_data = "H4sIAAAAAAAAA+3QwWqDQBAGYM99ii095FAaXe2u5FIISUisGKRpA/VSNrpo1GjY1UI89Nljekqh0FNoC/93mWVmYGdmL5VX6UZUsRzqzLgIq+cydorUZdZ5/GTfU8NyLcfpH9zq85Rxzg1iXWacr9p+eUWIsRMqlmXd6HfRfdf3U/2furk2W63MzbYyN0JnVzLOajLQOruTic0YHZFxb+IsOzGhZTT16PJ5xk45b+Gm813uiqeyyOvQ9wOHBbfJnKdBkU5H3iwq7Zf1nj++hpqsxxEJVZ3LuNFktVoQXx4G5IF8nJ/VHPb/mqJtslptO5m8FfKgf/tAAAAAAAAAAAAAAAAAAAAAAAAAf9QRk0aIXwAoAAA="
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


data "aws_ami" "ami" {
	most_recent = true
	owners = [ "self" ]
	
	filter {
		name = "name"
		values = [ "VAZ Projects Builder AMI" ]
	}
}