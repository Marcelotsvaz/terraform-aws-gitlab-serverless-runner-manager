# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import logging
import os
import json
import boto3



def main( event, context ):
	logging.getLogger().setLevel( logging.INFO )
	
	
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
		logging.info( 'Invalid request.' )
		return { 'statusCode': 400 }
	
	
	# Authorization.
	if event['headers']['x-gitlab-token'] != secretToken:
		logging.info( 'Invalid secret token.' )
		return { 'statusCode': 400 }
	
	
	# Check job status.
	logging.info( 'Job event: {jobStatus}' )
	if jobStatus != 'created':
		return { 'statusCode': 200 }
	
	
	# Launch runner.
	logging.info( 'Launching runner...' )
	ec2 = boto3.client( 'ec2' )
	response = ec2.modify_spot_fleet_request(
		SpotFleetRequestId = spotFleetId,
		TargetCapacity = 1,
	)
	
	if not response['Return']:
		logging.info( 'Error launching runner.' )
		return { 'statusCode': 400 }
	
	return { 'statusCode': 200 }