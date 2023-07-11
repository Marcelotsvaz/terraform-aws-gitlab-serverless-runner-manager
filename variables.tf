# 
# GitLab Serverless Runner Manager
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Name
#-------------------------------------------------------------------------------
variable name {
	description = "Name of the instance."
	type = string
}

variable identifier {
	description = "Unique identifier used in resources that need a unique name."
	type = string
}

variable prefix {
	description = "Unique prefix used in resources that need a globally unique name."
	type = string
}


# 
# Network
#-------------------------------------------------------------------------------
# variable subnet_id {
# 	description = "VPC subnet ID."
# 	type = string
# }

# variable vpc_security_group_ids {
# 	description = "Set of security group IDs."
# 	type = set( string )
# }


# 
# GitLab
#-------------------------------------------------------------------------------
variable gitlab_url {
	description = "URL of the GitLab instance."
	type = string
	default = "https://gitlab.com"
}

variable project_paths {
	description = "Set of projects that will have access to the runners through the runner's group."
	type = set( string )
}


# 
# Runners
#-------------------------------------------------------------------------------
variable runners {
	description = "Map of runner configurations."
	type = map( object( {
		# Registration.
		description = optional( string, "RunnerDesc" )
		access_level = optional( string, "ref_protected" )
		docker_privileged = optional( bool, false )
		locked = optional( bool, false )
		run_untagged = optional( bool, false )
		tag_list = optional( set( string ), [] )
		paused = optional( bool, false )
		maximum_timeout = optional( number, 3600 )
		
		# Worker.
		min_vcpu = number
		min_memory_mib = number
	} ) )
	
	validation {
		condition = alltrue( [
			for id, runner in var.runners : contains( [ "not_protected", "ref_protected" ], runner.access_level )
		] )
		error_message = "Expected access_level to be one of [not_protected ref_protected]."
	}
}



# 
# Locals
#-------------------------------------------------------------------------------
locals {
	bucket_prefix = "gitlabRunnerCache"
	
	runner_config_output = { for name, runner in var.runners : name => merge( runner, {
		name = name
		id = gitlab_runner.main[name].id
		authentication_token = gitlab_runner.main[name].authentication_token
		launch_template_id = aws_launch_template.main[name].id
	} ) }
	
	host_project = data.gitlab_project.main[keys( data.gitlab_project.main )[5]]
	runner_enablements = {
		for item in setproduct(
			values( local.runner_config_output ),
			values( data.gitlab_project.main ),
		)
		: "${item[0].name}-${item[1].path_with_namespace}" => { runner = item[0], project = item[1] }
		if item[1].path_with_namespace != local.host_project.path_with_namespace
	}
}