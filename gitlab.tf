# 
# GitLab Serverless Runner Manager
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



data gitlab_project main {
	for_each = var.project_paths
	
	path_with_namespace = each.value
}


resource gitlab_runner main {
	for_each = var.runners
	
	registration_token = local.host_project.runners_token
	
	access_level = each.value.access_level
	description = each.value.description
	locked = each.value.locked
	maximum_timeout = each.value.maximum_timeout
	paused = each.value.paused
	run_untagged = each.value.run_untagged
	tag_list = each.value.tag_list
}


resource gitlab_project_runner_enablement main {
	for_each = local.runner_enablements
	
	runner_id = each.value.runner.id
	project = each.value.project.id
}


resource random_password webhook_token {
	length = 64
}


resource gitlab_project_hook main {
	for_each = data.gitlab_project.main
	
	project = each.value.id
	
	url = "${aws_apigatewayv2_api.main.api_endpoint}${split( " ", aws_apigatewayv2_route.webhook_handler.route_key )[1]}"
	token = random_password.webhook_token.result
	job_events = true
	push_events = false
}


resource time_rotating main {
	rotation_months = 6
}


resource gitlab_project_access_token main {
	for_each = data.gitlab_project.main
	
	name = "${var.name} Job Match Token"
	project = each.value.id
	access_level = "reporter"
	scopes = [ "read_api" ]
	expires_at = formatdate( "YYYY-MM-DD", timeadd( time_rotating.main.rotation_rfc3339, "24h" ) )
}