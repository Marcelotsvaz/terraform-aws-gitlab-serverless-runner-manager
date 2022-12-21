# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



module "gitlab_runner" {
	source = "../"
	
	# Name.
	name = "${local.project_name} GitLab Runner"
	identifier = "gitlabRunner"
	prefix = local.project_code
	
	# Network.
	subnet_id = "subnet-08bbbb15ef90c7fda"
	vpc_security_group_ids = [ "sg-0f74c09e73e5919ac" ]
	
	# Tags.
	default_tags = local.default_tags
}