import json
import boto3
import os
from datetime import date
import shutil
from pathlib import Path



def handler(event, context):
    today= date.today()
    route53BackupPath = "/tmp/r53_backup"
    Path(route53BackupPath).mkdir(parents=True, exist_ok=True)
    print (today," Backup all Route53 zones and resource records.")
    route53Client = boto3.client('route53')
    listResponse = route53Client.list_hosted_zones()
    for hostedZone in listResponse['HostedZones']:
       Id= hostedZone['Id']
       name = hostedZone['Name']
       response = route53Client.list_resource_record_sets(HostedZoneId=Id)
       file = open(route53BackupPath+"/"+name+"json","w")
       file.write(json.dumps(response))
       file.close()
    shutil.make_archive("/tmp/route53Backup", 'zip', route53BackupPath)
    s3 = boto3.resource('s3')
    backupS3Name = os.getenv('s3_backup_bucket_name')
    s3.Object(backupS3Name, today.strftime('%m-%d-%Y')+"-route53Backup.zip").put(Body=open("/tmp/route53Backup.zip", 'rb'))