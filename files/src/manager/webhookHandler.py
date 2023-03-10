# 
# GitLab Serverless Runner Manager
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import logging
import json

from typing import Any

import boto3

from .common import env, HttpStatus



def main( event: dict[str, Any], context: Any ) -> dict[str, Any]:
	'''
	Handle Gitlab job events webhook.
	Invoke jobMatcher function when job status change to pending.
	'''
	
	del context	# Unused.
	
	
	# Validate request.
	try:
		if event['headers']['X-Gitlab-Event'] != 'Job Hook':
			raise ValueError( 'Webhook event isn\'t a job event.' )
		
		gitlabEventData = json.loads( event['body'] )
		projectId = gitlabEventData['project_id']
		jobId = gitlabEventData['build_id']
		jobStatus = gitlabEventData['build_status']
		isTag = gitlabEventData['tag']
		ref = gitlabEventData['ref']
	except ( KeyError, ValueError, json.JSONDecodeError ):
		logging.exception( 'Invalid request.' )
		
		return { 'statusCode': HttpStatus.BAD_REQUEST }
	
	
	# Check job status.
	logging.info( f'Job {jobId} status is {jobStatus}.' )
	if jobStatus != 'pending':
		return { 'statusCode': HttpStatus.OK }
	
	
	# Pass pending job to jobRequester lambda.
	boto3.client( 'lambda' ).invoke(	# pyright: ignore [reportUnknownMemberType]
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