# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import os
import boto3
import json
import logging



def main( event, context ):
	logging.getLogger().setLevel( logging.INFO )
	logging.info( event )	# TEMP
	
	
	# Env vars from Terraform.
	secretToken = os.environ['secretToken']
	spotFleetId = os.environ['spotFleetId']
	
	
	# Validate request.
	try:
		if event['headers']['x-gitlab-event'] != 'Job Hook':
			raise
		
		gitlabEventData = json.loads( event['body'] )
		jobStatus = gitlabEventData['build_status']
	except:
		logging.info( f'Invalid request.' )
		return { 'statusCode': 400 }
	
	
	# Authorization.
	if event['headers']['x-gitlab-token'] != secretToken:
		logging.info( f'Invalid secret token.' )
		return { 'statusCode': 400 }
	
	
	# Check job status.
	logging.info( f'Job event: {jobStatus}' )
	if jobStatus != 'created':
		return { 'statusCode': 200 }
	
	
	# Launch runner.
	logging.info( f'Launching runner...' )
	ec2 = boto3.client( 'ec2' )
	response = ec2.modify_spot_fleet_request(
		SpotFleetRequestId = spotFleetId,
		TargetCapacity = 1,
	)
	
	if not response['Return']:
		logging.info( f'Error launching runner.' )
		return { 'statusCode': 400 }
	
	return { 'statusCode': 200 }