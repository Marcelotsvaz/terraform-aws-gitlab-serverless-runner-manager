# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import logging
import os
import json
import boto3



# Monkey patch boto to convert all DynamoDB numbers to Python integers.
from boto3.dynamodb.types import TypeDeserializer
setattr( TypeDeserializer, '_deserialize_n', lambda _, number: int( number ) )



def main( event, context ):
	logging.getLogger().setLevel( logging.INFO )
	
	
	# Env vars from Terraform.
	runnerToken = os.environ['runnerToken']
	jobsTableName = os.environ['jobsTableName']
	
	
	# Authorization.
	if json.loads( event['body'] )['token'] != runnerToken:
		logging.info( 'Invalid runner token.' )
		return { 'statusCode': 400 }
	
	
	# Get pending job.
	workerId = event['pathParameters']['workerId']
	jobs = boto3.resource( 'dynamodb' ).Table( jobsTableName )
	
	if job := jobs.delete_item( Key = { 'workerId': workerId }, ReturnValues = 'ALL_OLD' ).get( 'Attributes' ):
		logging.info( f'Sending job {job["id"]} to worker {workerId}.' )
		
		return {
			"headers": {
				"Content-Type": "application/json",
			},
			"body": json.dumps( job['data'] ),
			"statusCode": 201,
		}
	else:
		logging.info( f'Terminating worker {workerId}.' )
		boto3.client( 'ec2' ).terminate_instances( InstanceIds = [ workerId ] )
		
		return { "statusCode": 204 }
	
	# except IndexError:
	# 	# No pending jobs.
	# 	logging.info( 'No pending jobs.' )
		
	# 	return { "statusCode": 204 }