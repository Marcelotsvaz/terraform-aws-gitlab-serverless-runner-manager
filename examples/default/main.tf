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
	
	# GitLab.
	project_id = var.gitlab_project_id
	
	# Runners.
	runner_config = [
		{
			description = "Runner 1"
			
			min_vcpu = 2
			min_memory_mib = 1024
		},
		{
			description = "Runner 2"
			run_untagged = false
			tag_list = [ "large" ]
			
			min_vcpu = 2
			min_memory_mib = 4096
		},
	]
	
	# Tags.
	default_tags = local.default_tags
}