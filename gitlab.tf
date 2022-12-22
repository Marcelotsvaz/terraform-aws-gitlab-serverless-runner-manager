# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



data "gitlab_project" "project" {
	path_with_namespace = var.project_id
}


resource "random_password" "webhook_token" {
	length = 64
}


resource "gitlab_project_hook" "hook" {
	project = data.gitlab_project.project.id
	
	url = aws_lambda_function_url.lambda_url.function_url
	token = random_password.webhook_token.result
	job_events = true
}


resource "gitlab_runner" "runner" {
	registration_token = data.gitlab_project.project.runners_token
}