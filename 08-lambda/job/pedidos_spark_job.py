import os
import sys
import boto3
from datetime import datetime

from pyspark.sql import SparkSession
from pyspark.sql.functions import *

print("Iniciando o script de processamento dos dados: pedidos_spark_job")
spark = SparkSession \
    .builder \
    .appName("pedidos_spark_job") \
    .config("hive.metastore.client.factory.class", "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory") \
    .enableHiveSupport() \
    .getOrCreate()

spark.catalog.setCurrentDatabase("dataengdb")

print("Definindo a variavel BUCKET_NAME que vamos utilizar ao longo do codigo")
BUCKET_NAME = ""
s3_client = boto3.client('s3')
response = s3_client.list_buckets()

for bucket in response['Buckets']:
    if bucket['Name'].startswith('dataeng-'):
        BUCKET_NAME = bucket['Name']
        break

print("O bucket que vamos utilizar serah: " + BUCKET_NAME)

print("Obtendo os dados de pedidos")
df_pedidos = spark.sql("select * from dataengdb.tb_raw_pedidos")
df_pedidos.show(5)

print("Escrevendo os dados de pedidos como parquet no S3")
df_pedidos.write.format("parquet").mode("overwrite").save(f"s3://{BUCKET_NAME}/stage/pedidos")

print("Finalizando o script de processamento dos dados: pedidos_spark_job")

