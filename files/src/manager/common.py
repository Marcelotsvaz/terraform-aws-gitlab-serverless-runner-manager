# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import os
import json

from enum import IntEnum
from types import SimpleNamespace



class httpStatus( IntEnum ):
	# Successful responses.
	ok = 200
	created = 201
	accepted = 202
	noContent = 204
	
	# Redirection responses.
	found = 302
	
	# Client error responses.
	badRequest = 400
	unauthorized = 401
	forbidden = 403
	notFound = 404
	conflict = 409
	
	# Server error responses.
	internalServerError = 500



env = SimpleNamespace( **json.loads( os.environ['terraformParameters'] ) )