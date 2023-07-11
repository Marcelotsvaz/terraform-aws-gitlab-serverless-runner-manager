# 
# GitLab Serverless Runner Manager
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



variable gitlab_access_token {
	description = "GitLab Personal Access Token with api scope."
	type = string
	sensitive = true
}


variable project_paths {
	description = "Set of projects that will have access to the runners through the runner's group."
	type = set( string )
}



locals {
	name = "Example GitLab Runner"
	prefix = "example"
	identifier = "gitlabRunner"
	
	default_tags = {
		Project = local.name
	}
}