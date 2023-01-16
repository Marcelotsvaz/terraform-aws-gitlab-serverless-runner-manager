# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import logging
import os
import json
import boto3
import requests



def main( event, context ):
	logging.getLogger().setLevel( logging.INFO )
	
	
	# Get job tags.
	url = os.environ['gitlabUrl']
	projectId = event['projectId']
	jobId = event['jobId']
	response = requests.get(
		f'{url}/api/v4/projects/{projectId}/jobs/{jobId}',
		headers = {
			'PRIVATE-TOKEN': os.environ['projectToken'],
		},
	)
	jobTags = set( response.json()['tag_list'] )
	logging.info( f'Job {jobId} tags: {", ".join( jobTags )}' )
	
	
	# Get matching runners.
	runners = json.loads( os.environ['runners'] )
	matchingRunners = []
	
	if jobTags:
		# Runner must support all tags set in job.
		matchingRunners = { id: runner for id, runner in runners.items() if not jobTags - set( runner['tag_list'] ) }
	else:
		# If job has no tags any runner with run_untagged set is valid.
		matchingRunners = { id: runner for id, runner in runners.items() if runner['run_untagged'] }
	
	if not matchingRunners:
		logging.error( f'No runners matched job {jobId} tags.' )	# TODO
		return
	
	logging.info( f'Job {jobId} matched runners with ID: {", ".join( matchingRunners )}' )
	
	# Trigger jobRequester function with selected runner.
	boto3.client( 'lambda' ).invoke(
		FunctionName = os.environ['jobRequesterFunctionArn'],
		InvocationType = 'Event',
		Payload = json.dumps( { 'runner': matchingRunners.popitem()[1] } ),
	)