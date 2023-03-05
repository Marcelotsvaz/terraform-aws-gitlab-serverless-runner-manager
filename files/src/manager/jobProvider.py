# 
# GitLab Serverless Runner Manager
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import logging
import json

from typing import Any

import boto3

from boto3.dynamodb.types import TypeDeserializer

from .common import env, HttpStatus



# Monkey patch boto to convert all DynamoDB numbers to Python integers.
# pylint: disable-next = line-too-long
setattr( TypeDeserializer, '_deserialize_n', lambda _, number: int( number ) )	# pyright: ignore [reportUnknownLambdaType, reportUnknownArgumentType]



def main( event: dict[str, Any], context: Any ) -> dict[str, Any]:
	'''
	Serve job requests from workers.
	'''
	
	del context	# Unused.
	
	
	# Authorization.
	requestToken = json.loads( event['body'] )['token']
	runnerTokens = [ runner['authentication_token'] for runner in env.runners.values() ]
	if requestToken not in runnerTokens:
		logging.error( 'Invalid runner authentication token.' )
		return { 'statusCode': HttpStatus.FORBIDDEN }
	
	
	# Return pending job.
	workerId = event['pathParameters']['workerId']
	dynamoDb = boto3.resource( 'dynamodb' )	# pyright: ignore [reportUnknownMemberType]
	job = dynamoDb.Table( env.jobsTableName ).delete_item(
		Key = { 'workerId': workerId },
		ReturnValues = 'ALL_OLD',
	).get( 'Attributes' )
	
	if not job:
		logging.info( f'Terminating worker {workerId}.' )
		
		ec2 = boto3.client( 'ec2' )	# pyright: ignore [reportUnknownMemberType]
		ec2.terminate_instances( InstanceIds = [ workerId ] )
		
		return { 'statusCode': HttpStatus.NO_CONTENT }
	
	logging.info( f'Sending job {job["id"]} to worker {workerId}.' )
	return {
		'headers': {
			'Content-Type': 'application/json',
		},
		'body': json.dumps( job['data'] ),
		'statusCode': HttpStatus.CREATED,
	}