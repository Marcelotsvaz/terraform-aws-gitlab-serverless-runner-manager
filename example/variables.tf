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
	project_name = "GitLab Runner"
	project_code = "gitlabRunner"
	region = "sa-east-1"
	
	default_tags = {
		Project = local.project_name
	}
}