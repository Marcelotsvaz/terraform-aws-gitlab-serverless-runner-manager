# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



variable "files" {
	description = "Raw files that will be added to the archive."
	type = set( string )
	default = []
}


variable "templates" {
	description = "Templates that will be rendered and added to the archive."
	type = set( string )
	default = []
}


variable "environment_file" {
	description = "Environment file constructed from var.environment."
	type = string
	default = "environment.env"
}


variable "context" {
	description = "Context variables for template substitution."
	type = map( string )
	default = {}
}


variable "environment" {
	description = "Environment variables."
	type = map( string )
	default = {}
}


variable "input_dir" {
	description = "Raw file and template location."
	type = string
	default = "."
}


variable "output_dir" {
	description = "Directory where rendered templates will be saved."
	type = string
	default = "/tmp/terraform"
}



locals {
	contents = [ for template in var.templates : base64encode( templatefile( "${var.input_dir}/${template}", var.context ) ) ]
	environment_rendered = base64encode( join( "\n", [ for key, value in var.environment : "${key}='${value}'" ] ) )
}