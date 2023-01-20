# 
# GitLab Serverless Runner Manager
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



variable "gitlab_access_token" {
	description = "GitLab Personal Access Token with api scope."
	type = string
	sensitive = true
}


variable "gitlab_project_id" {
	description = "GitLab Project ID."
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