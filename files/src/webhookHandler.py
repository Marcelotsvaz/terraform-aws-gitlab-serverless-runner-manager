# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import logging
import json
import boto3
import os



def main( event, context ):
	logging.getLogger().setLevel( logging.INFO )
	
	
	# Validate request.
	try:
		if event['headers']['X-Gitlab-Event'] != 'Job Hook':
			raise
		
		gitlabEventData = json.loads( event['body'] )
		jobId = gitlabEventData['build_id']
		jobStatus = gitlabEventData['build_status']
		projectId = gitlabEventData['project_id']
	except KeyError:	# TODO: Log error message.
		logging.error( 'Invalid request.' )
		
		return { 'statusCode': 400 }	# Bad request.
	
	
	# Check job status.
	logging.info( f'Job {jobId} status is {jobStatus}.' )
	if jobStatus != 'pending':
		return { 'statusCode': 200 }	# Ok.
	
	
	# Pass pending job to jobRequester lambda.
	boto3.client( 'lambda' ).invoke(
		FunctionName = os.environ['jobMatchersFunctionArn'],
		InvocationType = 'Event',
		Payload = json.dumps( {
			'jobId': jobId,
			'projectId': projectId
		} ),
	)
	
	return { 'statusCode': 202 }	# Accepted.