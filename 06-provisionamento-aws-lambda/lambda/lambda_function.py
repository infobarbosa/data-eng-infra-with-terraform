import boto3
import os

def lambda_handler(event, context):
    emr_client = boto3.client('emr')
    cluster_id = os.environ['EMR_CLUSTER_ID']
    step = {
        'Name': 'Process CSV File',
        'ActionOnFailure': 'CONTINUE',
        'HadoopJarStep': {
            'Jar': 'command-runner.jar',
            'Args': ['spark-submit', 's3://path-to-your-bucket/scripts/spark_job.py']
        }
    }
    response = emr_client.add_job_flow_steps(
        JobFlowId=cluster_id,
        Steps=[step]
    )
    return response