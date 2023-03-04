# 
# GitLab Serverless Runner Manager
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 4.57"
		}
		
		gitlab = {
			source = "gitlabhq/gitlab"
			version = "~> 15.9"
		}
	}
	
	required_version = ">= 1.3.6"
}