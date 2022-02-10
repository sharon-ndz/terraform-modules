import boto3
import os
from datetime import date
def handler(event, context):
    s3 = boto3.resource('s3')
    sourceS3Name = os.getenv('s3_source_bucket_name')
    destS3Name = os.getenv('s3_dest_bucket_name')
    destBucket = s3.Bucket(destS3Name)
    s3Client = boto3.client('s3')
    paginator = s3Client.get_paginator('list_objects_v2')
    pages = paginator.paginate(Bucket= sourceS3Name)
    today= date.today()

    for page in pages:
        for obj in page['Contents']:
            copy_source = {
            'Bucket': sourceS3Name,
            'Key': obj['Key']
            }
            destBucket.copy(copy_source, today.strftime('%m-%d-%Y')+"/"+obj['Key'])
