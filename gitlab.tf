# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



data "gitlab_project" "main" {
	path_with_namespace = var.project_id
}


resource "random_password" "webhook_token" {
	length = 64
}


resource "gitlab_project_hook" "main" {
	project = data.gitlab_project.main.id
	
	url = module.job_requester.function_url
	token = random_password.webhook_token.result
	job_events = true
	push_events = false
}


resource "gitlab_runner" "main" {
	registration_token = data.gitlab_project.main.runners_token
}