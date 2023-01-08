# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import logging
import os
import requests



def main( event, context ):
	logging.getLogger().setLevel( logging.INFO )
	
	
	# Env vars from Terraform.
	runnerToken = os.environ['runnerToken']
	gitlabUrl = os.environ['gitlabUrl']
	
	
	# Get new jobs.
	response = requests.post( f'{gitlabUrl}/api/v4/jobs/request', json = {
		'token': runnerToken,
	} )
	
	if response.status_code == 204:
		logging.info( 'No new jobs.' )
	elif response.status_code == 201:
		jobId = response.json()['job_info']['id']
		logging.info( f'New job found. ID: {jobId}' )
	else:
		logging.error( f'Error. Response code is {response.status_code}' )