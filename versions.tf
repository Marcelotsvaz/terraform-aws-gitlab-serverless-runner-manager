# 
# GitLab Serverless Runner Manager
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = ">= 4.57"
		}
		
		gitlab = {
			source = "gitlabhq/gitlab"
			version = ">= 16.0"
		}
		
		archive = {
			source = "hashicorp/archive"
			version = ">= 2.3"
		}
		
		random = {
			source = "hashicorp/random"
			version = ">= 3.4"
		}
		
		time = {
			source = "hashicorp/time"
			version = ">= 0.9"
		}
	}
	
	required_version = ">= 1.3.6"
}