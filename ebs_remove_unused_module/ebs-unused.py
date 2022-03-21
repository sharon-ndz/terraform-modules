import json
import itertools
from datetime import datetime, timedelta
import os, os.path, sys
import boto3
import botocore
from botocore.exceptions import ClientError
from dateutil.parser import parse
import datetime
from dateutil.tz import tzlocal


def getAvailableVolumes(rgn):
    # returns list of volumes in 'available' state
    ec2 = boto3.client('ec2', region_name=rgn)
    availableVolList = set()
    filterList = [{'Name': 'status', 'Values': ['available']}]
    hasNextToken = True
    while(hasNextToken):
        response = ec2.describe_volumes(Filters=filterList)
        hasNextToken = 'NextToken' in response
        for v in response['Volumes']:
            if 'Tags' in v:
                exists = False
                for tag in v['Tags']:
                    if tag['Key'] == "Retain" and tag['Value'] == "true":
                        exists = True
                if exists == False:
                    availableVolList.add(v['VolumeId'])
            else:
                availableVolList.add(v['VolumeId'])
    return availableVolList



def lambda_handler(event, context):
    # gather data to build OpsItem request
    print("boto3 version:"+boto3.__version__)
    print("botocore version:"+botocore.__version__)
    acctID = context.invoked_function_arn.split(":")[4]
    rgn = os.environ["AWS_REGION"] # used with Lambda to get the current region
    # collect available EBS volumes and attachment history
    availableVols = getAvailableVolumes(rgn)
    client = boto3.client('ec2')
    for ebs in availableVols:
        print("deleted vol = " + str(ebs))
        client.delete_volume(VolumeId=ebs)