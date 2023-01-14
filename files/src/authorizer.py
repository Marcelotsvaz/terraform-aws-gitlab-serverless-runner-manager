# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import logging
import os

from hmac import compare_digest



def main( event, context ):
	logging.getLogger().setLevel( logging.INFO )
	
	# Authorization.
	isAuthorized = compare_digest( event['identitySource'][0], os.environ['token'] )	# Use constant time string comparison to prevent timing attacks.
	return { 'isAuthorized': isAuthorized }