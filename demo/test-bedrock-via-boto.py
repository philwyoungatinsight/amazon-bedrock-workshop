#!/usr/bin/env python3
import json
import os
import sys

import boto3

module_path = ".."
sys.path.append(os.path.abspath(module_path))
from utils import bedrock, print_ww

# Added
import json

# ---- ⚠️ Un-comment and edit the below lines as needed for your AWS setup ⚠️ ----

# os.environ["AWS_DEFAULT_REGION"] = "<REGION_NAME>"  # E.g. "us-east-1"
# os.environ["AWS_PROFILE"] = "<YOUR_PROFILE>"
# os.environ["BEDROCK_ASSUME_ROLE"] = "<YOUR_ROLE_ARN>"  # E.g. "arn:aws:..."
# os.environ["BEDROCK_ENDPOINT_URL"] = "<YOUR_ENDPOINT_URL>"  # E.g. "https://..."

os.environ["AWS_DEFAULT_REGION"] = "us-west-2"
#os.environ["AWS_PROFILE"] = "bedrock"  # Fails if we set this, per above
#
# TODO: Let them know their docs are wrong
# os.environ["AWS_PROFILE"]  should be os.environ["AWS_PROFILE_NAME"]
#
os.environ["AWS_PROFILE_NAME"] = "bedrock"

print("About to create boto3 client")

boto3_bedrock = bedrock.get_bedrock_client(
    assumed_role=os.environ.get("BEDROCK_ASSUME_ROLE", None),
    endpoint_url=os.environ.get("BEDROCK_ENDPOINT_URL", None),
    region=os.environ.get("AWS_DEFAULT_REGION", None),
)

# print("About to test boto3 client")

# https://github.com/aws-samples/amazon-bedrock-workshop/blob/cdf2d6538850800e8363163a6d330e54e8b9c604/00_Intro/bedrock_boto3_setup.ipynb
# boto3_bedrock.list_foundation_models()

jd = json.dumps(boto3_bedrock.list_foundation_models())
print( jd )

boto3_bedrock.
