# 
# GitLab Serverless Runner Manager
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from typing import Any
from hmac import compare_digest

from .common import env



def main( event: dict[str, Any], context: Any ) -> dict[str, Any]:
	'''
	Authorize API calls using HTTP headers.
	'''
	
	del context	# Unused.
	
	
	# Authorization.
	# Use constant time string comparison to prevent timing attacks.
	isAuthorized = compare_digest( event['identitySource'][0], env.token )
	return { 'isAuthorized': isAuthorized }