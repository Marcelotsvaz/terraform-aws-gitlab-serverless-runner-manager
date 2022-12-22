# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



data "gitlab_project" "project" {
	path_with_namespace = var.project_id
}


resource "gitlab_runner" "runner" {
	registration_token = data.gitlab_project.project.runners_token
}