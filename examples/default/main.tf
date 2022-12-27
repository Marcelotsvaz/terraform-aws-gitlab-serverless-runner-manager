# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



module "gitlab_runner" {
	source = "../../"
	
	# Name.
	name = local.name
	prefix = local.prefix
	identifier = local.identifier
	
	# Network.
	subnet_id = "subnet-08bbbb15ef90c7fda"
	vpc_security_group_ids = [ "sg-0f74c09e73e5919ac" ]
	
	# GitLab
	project_id = var.gitlab_project_id
	
	# Tags.
	default_tags = local.default_tags
}