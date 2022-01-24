#!/usr/bin/env python

import io
import boto3
import os
import json


def lambda_handler(event, context):

    # static variables
    S3_BUCKET = os.getenv('s3_bucket_name')
    AWS_REGION = os.getenv('region')

    # param variables
    str_params = ''

    # boto
    s3 = boto3.client('s3', region_name = AWS_REGION)
    ssm = boto3.client('ssm', region_name = AWS_REGION)

    # get values
    paginator = ssm.get_paginator('get_parameters_by_path')
    for page in paginator.paginate(Path='/', WithDecryption=True, Recursive=True):
        for item in page['Parameters']:
            str_params += json.dumps(item, default=str) + "\n"
    #dump to json/s3            
    payload = io.StringIO(str_params)
    s3.put_object(Bucket=S3_BUCKET, Key="paramstore_backup.csv", Body=payload.read(), ServerSideEncryption='AES256')



