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
	projectId = event['projectId']
	jobId = event['jobId']
	url = 'https://gitlab.com'
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
	
	
	# Get new jobs.
	# if job := requestJob( gitlabUrl, runnerToken ):
	# 	# Create worker.
	# 	fleetRequest = boto3.client( 'ec2' ).create_fleet(
	# 		Type = 'instant',
	# 		TargetCapacitySpecification = {
	# 			'DefaultTargetCapacityType': 'spot',
	# 			'TotalTargetCapacity': 1,
	# 		},
	# 		LaunchTemplateConfigs = [
	# 			{
	# 				'LaunchTemplateSpecification': {
	# 					'LaunchTemplateId': launchTemplateId,
	# 					'Version': launchTemplateVersion,
	# 				},
	# 				'Overrides': [ { 'SubnetId': subnetId } for subnetId in subnetIds ],
	# 			},
	# 		],
	# 	)
		
	# 	for error in fleetRequest['Errors']:
	# 		logging.warning( error )
		
	# 	if len( fleetRequest['Instances'] ) == 0:
	# 		logging.error( 'Couldn\'t create worker.' )
	# 		return { 'statusCode': 500 }	# Internal server error.
		
		
	# 	# Register job.
	# 	jobId = job['job_info']['id']
	# 	workerId = fleetRequest['Instances'][0]['InstanceIds'][0]
	# 	workerType = fleetRequest['Instances'][0]['InstanceType']
	# 	jobs = boto3.resource( 'dynamodb' ).Table( jobsTableName )
	# 	jobs.put_item(
	# 		Item = {
	# 			'id': jobId,
	# 			'workerId': workerId,
	# 			'data': job,
	# 		}
	# 	)
		
	# 	logging.info( f'Assigned job {jobId} to worker {workerId} ({workerType}).' )
	
	# return { 'statusCode': 201 }	# Created.
		



def requestJob( url, runnerToken ):
	'''
	
	'''
	
	response = requests.post( f'{url}/api/v4/jobs/request', json = {
		'token': runnerToken,
	} )
	
	if response.status_code == 201:
		return response.json()
	elif response.status_code == 204:
		return None
	else:
		raise Exception( f'Invalid status code ({response.status_code}) while requesting job.' )