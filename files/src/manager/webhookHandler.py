# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import logging
import json
import boto3

from .common import env, httpStatus



def main( event, context ):
	# Validate request.
	try:
		if event['headers']['X-Gitlab-Event'] != 'Job Hook':
			raise
		
		gitlabEventData = json.loads( event['body'] )
		projectId = gitlabEventData['project_id']
		jobId = gitlabEventData['build_id']
		jobStatus = gitlabEventData['build_status']
		isTag = gitlabEventData['tag']
		ref = gitlabEventData['ref']
	except KeyError:	# TODO: Log error message.
		logging.error( 'Invalid request.' )
		
		return { 'statusCode': httpStatus.badRequest }
	
	
	# Check job status.
	logging.info( f'Job {jobId} status is {jobStatus}.' )
	if jobStatus != 'pending':
		return { 'statusCode': httpStatus.ok }
	
	
	# Pass pending job to jobRequester lambda.
	boto3.client( 'lambda' ).invoke(
		FunctionName = env.jobMatchersFunctionArn,
		InvocationType = 'Event',
		Payload = json.dumps( {
			'projectId': projectId,
			'jobId': jobId,
			'isTag': isTag,
			'ref': ref,
		} ),
	)
	
	return { 'statusCode': httpStatus.accepted }