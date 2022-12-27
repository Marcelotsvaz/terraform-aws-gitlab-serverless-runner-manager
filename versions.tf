# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = ">= 4.48"
		}
		
		gitlab = {
			source = "gitlabhq/gitlab"
			version = ">= 3.20"
		}
		
		archive = {
			source = "hashicorp/archive"
			version = ">= 2.2"
		}
		
		random = {
			source = "hashicorp/random"
			version = ">= 3.4"
		}
	}
	
	required_version = ">= 1.3.6"
}