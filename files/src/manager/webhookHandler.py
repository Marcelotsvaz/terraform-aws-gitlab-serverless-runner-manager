# 
# GitLab Serverless Runner Manager
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import logging
import json
import boto3

from .common import env, HttpStatus



def main( event, context ):
	'''
	Handle Gitlab job events webhook.
	Invoke jobMatcher function when job status change to pending.
	'''
	
	del context	# Unused.
	
	
	# Validate request.
	try:
		if event['headers']['X-Gitlab-Event'] != 'Job Hook':
			raise KeyError
		
		gitlabEventData = json.loads( event['body'] )
		projectId = gitlabEventData['project_id']
		jobId = gitlabEventData['build_id']
		jobStatus = gitlabEventData['build_status']
		isTag = gitlabEventData['tag']
		ref = gitlabEventData['ref']
	except KeyError:	# TODO: Log error message.
		logging.error( 'Invalid request.' )
		
		return { 'statusCode': HttpStatus.BAD_REQUEST }
	
	
	# Check job status.
	logging.info( f'Job {jobId} status is {jobStatus}.' )
	if jobStatus != 'pending':
		return { 'statusCode': HttpStatus.OK }
	
	
	# Pass pending job to jobRequester lambda.
	boto3.client( 'lambda' ).invoke(
		FunctionName = env.jobMatcherFunctionArn,
		InvocationType = 'Event',
		Payload = json.dumps( {
			'projectId': projectId,
			'jobId': jobId,
			'isTag': isTag,
			'ref': ref,
		} ),
	)
	
	return { 'statusCode': HttpStatus.ACCEPTED }