# 
# GitLab Serverless Runner Manager
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import logging
import json

from typing import Any

import requests
import boto3

from .common import env



def main( event: dict[str, Any], context: Any ) -> None:
	'''
	Find a suitable runner for the job based on job tags and protected status.
	'''
	
	del context	# Unused.
	
	
	# Get job tags.
	projectId = event['projectId']
	jobId = event['jobId']
	response = requests.get(
		url = f'{env.gitlabUrl}/api/v4/projects/{projectId}/jobs/{jobId}',
		headers = { 'Private-Token': env.projectTokens[str( projectId )] },
		timeout = 5,
	)
	jobTags = set( response.json()['tag_list'] )
	logging.info( f'Job {jobId} tags: {", ".join( jobTags )}' )
	
	
	# Get matching runners.
	matchingRunners = []
	
	if jobTags:
		# Runner must support all tags set in job.
		matchingRunners = {
			name: runner for name, runner in env.runners.items()
			if not jobTags - set( runner['tag_list'] )
		}
	else:
		# If job has no tags any runner with run_untagged set is valid.
		matchingRunners = {
			name: runner for name, runner in env.runners.items()
			if runner['run_untagged']
		}
	
	if not matchingRunners:
		logging.error( f'No runners matched job {jobId} tags.' )	# TODO: Fail job?
		return
	
	logging.info( f'Job {jobId} tags matched runners with ID: {", ".join( matchingRunners )}' )
	
	
	# Handle unprotected jobs.
	if unprotectedRunners := {
		name: runner for name, runner in matchingRunners.items()
		if runner['access_level'] == 'not_protected'
	}:
		_, runner = unprotectedRunners.popitem()
	else:
		# Matched runners only accept protected jobs, check if branch or tag is protected.
		refType = 'tags' if event['isTag'] else 'branches'
		ref = event['ref']
		
		response = requests.get(
			url = f'{env.gitlabUrl}/api/v4/projects/{projectId}/repository/{refType}/{ref}',
			headers = { 'Private-Token': env.projectTokens[str( projectId )] },
			timeout = 5,
		)
		
		if not response.json()['protected']:
			logging.error( f'No runners matched protected job {jobId}.' )
			return
		
		_, runner = matchingRunners.popitem()
	
	logging.info( f'Job {jobId} matched runner with ID: {runner["name"]}' )
	
	
	# Trigger jobRequester function with selected runner.
	boto3.client( 'lambda' ).invoke(	# pyright: ignore [reportUnknownMemberType]
		FunctionName = env.jobRequesterFunctionArn,
		InvocationType = 'Event',
		Payload = json.dumps( { 'runner': runner } ),
	)