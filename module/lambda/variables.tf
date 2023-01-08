# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Name.
#-------------------------------------------------------------------------------
variable "name" {
	description = "Name of the function."
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


# Code.
#-------------------------------------------------------------------------------
variable "source_dir" {
	description = "Path of module."
	type = string
}

variable "handler" {
	description = "Lambda function entrypoint."
	type = string
}

variable "timeout" {
	description = "Lambda function timeout."
	type = number
}

variable "environment" {
	description = "Environment variables."
	type = map( string )
	default = {}
}



# Locals.
#-------------------------------------------------------------------------------
locals {
	lambda_function_name = "${var.prefix}-${var.identifier}-lambda"	# Avoid cyclic dependency.
}