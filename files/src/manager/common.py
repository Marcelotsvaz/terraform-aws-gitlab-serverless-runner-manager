# 
# GitLab Serverless Runner Manager
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import os
import json

from enum import IntEnum
from types import SimpleNamespace



class HttpStatus( IntEnum ):
	'''
	Enum representing HTTP response status codes.
	'''
	
	# Successful responses.
	OK = 200
	CREATED = 201
	ACCEPTED = 202
	NO_CONTENT = 204
	
	# Redirection responses.
	FOUND = 302
	
	# Client error responses.
	BAD_REQUEST = 400
	UNAUTHORIZED = 401
	FORBIDDEN = 403
	NOT_FOUND = 404
	CONFLICT = 409
	
	# Server error responses.
	INTERNAL_SERVER_ERROR = 500



env = SimpleNamespace( **json.loads( os.environ['terraformParameters'] ) )