# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 4.47"
		}
		
		gitlab = {
			source = "gitlabhq/gitlab"
			version = "~> 3.20"
		}
	}
	
	required_version = ">= 1.3.6"
}