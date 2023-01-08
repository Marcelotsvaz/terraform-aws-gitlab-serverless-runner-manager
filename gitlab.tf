# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



data "gitlab_project" "main" {
	path_with_namespace = var.project_id
}


resource "gitlab_runner" "main" {
	registration_token = data.gitlab_project.main.runners_token
}