# 
# GitLab Serverless Runner Manager
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import logging

from typing import Any, Optional

import requests
import boto3

from .common import env, HttpStatus



def main( event: dict[str, Any], context: Any ) -> None:
	'''
	Request a job from GitLab for a specific runner and launch a worker for it.
	'''
	
	del context	# Unused.
	
	
	# Get new jobs.
	runner = event['runner']
	job = requestJob( env.gitlabUrl, runner )
	if not job:
		logging.warning( f'No jobs available for runner {runner["id"]}.' )
		return
	
	
	# Create worker.
	fleetRequest = boto3.client( 'ec2' ).create_fleet(	# pyright: ignore [reportUnknownMemberType]
		Type = 'instant',
		TargetCapacitySpecification = {
			'DefaultTargetCapacityType': 'spot',
			'TotalTargetCapacity': 1,
		},
		SpotOptions = { 'AllocationStrategy': 'price-capacity-optimized' },
		LaunchTemplateConfigs = [
			{
				'LaunchTemplateSpecification': {
					'LaunchTemplateId': runner['launch_template_id'],
					'Version': '$Default',
				},
				'Overrides': [ { 'SubnetId': subnetId } for subnetId in env.subnetIds ],
			},
		],
	)
	
	for error in fleetRequest['Errors']:
		logging.warning( error )
	
	# Register job.
	try:
		jobId = job['job_info']['id']
		instance = fleetRequest['Instances'][0]
		workerId = instance['InstanceIds'][0]
		workerType = instance['InstanceType']
	except ( KeyError, IndexError ):
		logging.error( 'Couldn\'t create worker.' )
		return
	
	dynamoDb = boto3.resource( 'dynamodb' )	# pyright: ignore [reportUnknownMemberType]
	dynamoDb.Table( env.jobsTableName ).put_item(
		Item = {
			'id': jobId,
			'workerId': workerId,
			'data': job,
		}
	)
	
	logging.info(
		f'Assigned job {jobId} to worker {workerId} ({workerType}) of runner {runner["id"]}.'
	)



def requestJob( gitlabUrl: str, runner: dict[str, Any] ) -> Optional[dict[str, Any]]:
	'''
	Request a job from GitLab for a specific runner.
	'''
	
	requestData = {
		'token': runner['authentication_token'],
		'info': {
			'features': {
				'artifacts_exclude': True,
				'artifacts': True,
				'cache': True,
				'cancelable': True,
				'image': True,
				'masking': True,
				'multi_build_steps': True,
				'proxy': False,
				'raw_variables': True,
				'refspecs': True,
				'return_exit_code': True,
				'service_variables': True,
				'services': True,
				'session': True,
				'shared': False,
				'terminal': True,
				'trace_checksum': True,
				'trace_reset': True,
				'trace_size': True,
				'upload_multiple_artifacts': True,
				'upload_raw_artifacts': True,
				'variables': True,
				'vault_secrets': True,
			}
		}
	}
	
	response = requests.post(
		url = f'{gitlabUrl}/api/v4/jobs/request',
		json = requestData,
		timeout = 30,
	)
	
	if response.status_code == HttpStatus.CREATED:
		return response.json()
	
	if response.status_code == HttpStatus.NO_CONTENT:
		return None
	
	raise InvalidJobResponse( f'Invalid status code ({response.status_code}) while requesting job.' )



class InvalidJobResponse( Exception ):
	'''
	Response from /api/v4/jobs/request has invalid status code.
	'''