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
	
	# GitLab
	project_id = var.gitlab_project_id
	
	# Tags.
	default_tags = local.default_tags
}