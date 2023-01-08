# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import logging
import os
import boto3
import requests



def main( event, context ):
	logging.getLogger().setLevel( logging.INFO )
	
	
	# Env vars from Terraform.
	runnerToken = os.environ['runnerToken']
	gitlabUrl = os.environ['gitlabUrl']
	jobsTableName = os.environ['jobsTableName']
	
	
	# Get DynamoDB table.
	table = boto3.resource( 'dynamodb' ).Table( jobsTableName )
	
	
	# Get new jobs.
	while job := requestJob( gitlabUrl, runnerToken ):
		jobId = job['job_info']['id']
		logging.info( f'Found new job. ID: {jobId}' )
		
		table.put_item( Item = job )
		



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