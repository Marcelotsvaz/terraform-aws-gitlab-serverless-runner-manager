# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



locals {
	project_name = "GitLab Runner"
	project_code = "gitlabRunner"
	region = "sa-east-1"
	
	default_tags = {
		Project = local.project_name
	}
}