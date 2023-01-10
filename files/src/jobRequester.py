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
	
	
	# Env vars from Terraform.
	webhookToken = os.environ['webhookToken']
	runnerToken = os.environ['runnerToken']
	gitlabUrl = os.environ['gitlabUrl']
	jobsTableName = os.environ['jobsTableName']
	
	
	# Validate request.
	try:
		if event['headers']['x-gitlab-event'] != 'Job Hook':
			raise
		
		gitlabEventData = json.loads( event['body'] )
		jobId = gitlabEventData['build_id']
		jobStatus = gitlabEventData['build_status']
	except:
		logging.info( 'Invalid request.' )
		
		return { 'statusCode': 400 }
	
	
	# Authorization.
	if event['headers']['x-gitlab-token'] != webhookToken:
		logging.info( 'Invalid webhook token.' )
		
		return { 'statusCode': 403 }
	
	
	# Check job status.
	logging.info( f'Job {jobId} status is {jobStatus}.' )
	if jobStatus != 'pending':
		return { 'statusCode': 200 }
	
	
	# Get DynamoDB table.
	table = boto3.resource( 'dynamodb' ).Table( jobsTableName )
	
	
	# Get new jobs.
	if job := requestJob( gitlabUrl, runnerToken ):
		jobId = job['job_info']['id']
		logging.info( f'Accepted job {jobId}.' )
		
		table.put_item( Item = job )
	
	return { 'statusCode': 200 }
		



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