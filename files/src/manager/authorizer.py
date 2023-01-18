# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from hmac import compare_digest

from .common import env



def main( event, context ):
	# Authorization.
	isAuthorized = compare_digest( event['identitySource'][0], env.token )	# Use constant time string comparison to prevent timing attacks.
	return { 'isAuthorized': isAuthorized }