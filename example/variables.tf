# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



variable "gitlab_access_token" {
	description = ""
	type = string
	sensitive = true
}


variable "gitlab_project_id" {
	description = ""
	type = string
}



locals {
	name = "Example GitLab Runner"
	prefix = "example"
	identifier = "gitlabRunner"
	
	default_tags = {
		Project = local.name
	}
}