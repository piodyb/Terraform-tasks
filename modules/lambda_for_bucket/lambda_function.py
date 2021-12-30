from __future__ import print_function
import boto3
import urllib
import random

s3 = boto3.client('s3')
resource = boto3.resource('s3')

def lambda_handler(event, context):
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    object_key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    bucketlist = []
    for b in resource.buckets.all():
        bucketlist.append(b.name)
    try:
        bucketlist.remove(source_bucket) 
    except:
        pass
    target_bucket = random.choice(bucketlist)
    copy_source = {'Bucket': source_bucket, 'Key': object_key}
    try:
        waiter = s3.get_waiter('object_exists')
        waiter.wait(Bucket=source_bucket, Key=object_key)
        s3.copy_object(Bucket=target_bucket, Key=object_key, CopySource=copy_source)
    except Exception as err:
        print ("Error -"+str(err))
    return