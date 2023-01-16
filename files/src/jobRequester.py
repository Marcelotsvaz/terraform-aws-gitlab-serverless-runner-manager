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
	
	logging.info( event )
	
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