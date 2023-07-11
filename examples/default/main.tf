# 
# GitLab Serverless Runner Manager
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



module gitlab_runner {
	source = "../../"
	
	# Name.
	name = local.name
	prefix = local.prefix
	identifier = local.identifier
	
	# GitLab.
	project_paths = var.project_paths
	
	# Runners.
	runners = {
		default = {
			description = "Default Runner"
			access_level = "not_protected"
			run_untagged = true
			
			min_vcpu = 2
			min_memory_mib = 1024
		}
		
		protected = {
			description = "Protected Runner"
			docker_privileged = true
			run_untagged = true
			tag_list = [ "docker" ]
			
			min_vcpu = 2
			min_memory_mib = 1024
		}
		
		# protected_large = {
		# 	description = "Protected Runner (Large)"
		# 	docker_privileged = true
		# 	tag_list = [ "docker", "large" ]
			
		# 	min_vcpu = 2
		# 	min_memory_mib = 4096
		# }
	}
}