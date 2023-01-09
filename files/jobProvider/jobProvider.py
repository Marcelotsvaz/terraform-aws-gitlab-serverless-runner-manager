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
	
	
	# .
	requestBody = json.loads( event['body'] )
	
	
	# Authorization.
	if requestBody['token'] != runnerToken:
		logging.info( 'Invalid runner token.' )
		return { 'statusCode': 400 }
	
	
	# Get DynamoDB table.
	table = boto3.resource( 'dynamodb' ).Table( jobsTableName )
	
	
	# Get pending job.
	try:
		jobId = table.scan( Limit = 1 )['Items'][0]['id']
		job = table.delete_item( Key = { 'id': jobId }, ReturnValues = 'ALL_OLD' )['Attributes']
		
		# Job found.
		logging.info( f'Sending job {jobId} to runner.' )
		
		return {
			"headers": {
				"Content-Type": "application/json",
			},
			"body": json.dumps( job ),
			"statusCode": 201,
		}
		
	except IndexError:
		# No pending jobs.
		logging.info( 'No pending jobs.' )
		
		return { "statusCode": 204 }