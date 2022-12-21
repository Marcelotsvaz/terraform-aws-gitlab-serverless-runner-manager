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
	}
	
	required_version = ">= 1.3.6"
}


provider "aws" {
	region = local.region
	
	default_tags { tags = local.default_tags }
}