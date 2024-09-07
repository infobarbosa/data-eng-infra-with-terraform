import boto3
import os

def lambda_handler(event, context):
    emr_client = boto3.client('emr')
    dataeng_cluster_id = os.environ['EMR_CLUSTER_ID']
    dataeng_bucket_name = os.environ['DATAENG_BUCKET_NAME']

    step = {
        'Name': 'Processamento de pedidos',
        'ActionOnFailure': 'CONTINUE',
        'HadoopJarStep': {
            'Jar': 'command-runner.jar',
            'Args': ['spark-submit', f's3://{dataeng_bucket_name}/scripts/pedido_spark_job.py']
        }
    }
    response = emr_client.add_job_flow_steps(
        JobFlowId=dataeng_cluster_id,
        Steps=[step]
    )
    return response