from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("CSV to Parquet").getOrCreate()

# Ler o arquivo CSV do S3
df = spark.read.csv("s3://path-to-your-bucket/input-data/", header=True, inferSchema=True)

# Escrever o arquivo Parquet no S3
df.write.parquet("s3://path-to-your-bucket/output-data/")

spark.stop()