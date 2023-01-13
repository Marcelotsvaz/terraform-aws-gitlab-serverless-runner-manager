# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Name.
#-------------------------------------------------------------------------------
variable "name" {
	description = "Name of the instance."
	type = string
}

variable "identifier" {
	description = "Unique identifier used in resources that need a unique name."
	type = string
}

variable "prefix" {
	description = "Unique prefix used in resources that need a globally unique name."
	type = string
}


# 
# Network.
#-------------------------------------------------------------------------------
# variable "subnet_id" {
# 	description = "VPC subnet ID."
# 	type = string
# }

# variable "vpc_security_group_ids" {
# 	description = "Set of security group IDs"
# 	type = set( string )
# }


# 
# GitLab.
#-------------------------------------------------------------------------------
variable "project_id" {
	description = ""
	type = string
}


# 
# Name.
#-------------------------------------------------------------------------------
variable "runner_config" {
	description = ""
	type = list( object( {
		# Registration.
		access_level = optional( string, "ref_protected" )
		description = optional( string, "RunnerDesc" )
		locked = optional( bool, false )
		maximum_timeout = optional( number, 3600 )
		paused = optional( bool, false )
		run_untagged = optional( bool, true )
		tag_list = optional( set( string ), [] )
		
		# Worker.
		name = optional( string, "RunnerName" )
		min_vcpu = number
		min_memory_mib = number
	} ) )
}


# 
# Tags.
#-------------------------------------------------------------------------------
variable "default_tags" {
	description = "Tags to be applied to all resources."
	type = map( string )
	default = {}
}



# 
# Locals.
#-------------------------------------------------------------------------------
locals {
	bucket_prefix = "gitlabRunnerCache"
	runner_config_map = { for index, config in var.runner_config : index => config }
}