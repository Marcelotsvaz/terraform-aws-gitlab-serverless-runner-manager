# 
# GitLab Serverless Runner Manager
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



data gitlab_project main {
	path_with_namespace = var.project_id
}


resource random_password webhook_token {
	length = 64
}


resource gitlab_project_hook main {
	project = data.gitlab_project.main.id
	
	url = "${aws_apigatewayv2_api.main.api_endpoint}${split( " ", aws_apigatewayv2_route.webhook_handler.route_key )[1]}"
	token = random_password.webhook_token.result
	job_events = true
	push_events = false
}


resource gitlab_runner main {
	for_each = var.runners
	
	registration_token = data.gitlab_project.main.runners_token
	
	access_level = each.value.access_level
	description = each.value.description
	locked = each.value.locked
	maximum_timeout = each.value.maximum_timeout
	paused = each.value.paused
	run_untagged = each.value.run_untagged
	tag_list = each.value.tag_list
}


resource gitlab_project_access_token main {
	name = "${var.name} Job Read Token"
	project = data.gitlab_project.main.id
	scopes = [ "read_api" ]
}