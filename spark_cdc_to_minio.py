#!/usr/bin/env python3
"""
Script para ler eventos CDC do Kafka e escrever para MinIO usando Spark
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col, when
from pyspark.sql.types import StructType, StructField, StringType, LongType, TimestampType

# Criar SparkSession
spark = SparkSession.builder \
    .appName("CDC_Kafka_to_MinIO") \
    .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.4.0") \
    .getOrCreate()

# Definir schema do Debezium envelope
debezium_schema = StructType([
    StructField("before", StructType([
        StructField("id", LongType()),
        StructField("nome", StringType()),
        StructField("sexo", StringType()),
        StructField("dt_nasc", StringType()),
        StructField("created_at", TimestampType()),
        StructField("updated_at", TimestampType()),
    ]), True),
    StructField("after", StructType([
        StructField("id", LongType()),
        StructField("nome", StringType()),
        StructField("sexo", StringType()),
        StructField("dt_nasc", StringType()),
        StructField("created_at", TimestampType()),
        StructField("updated_at", TimestampType()),
    ]), True),
    StructField("op", StringType()),
    StructField("ts_ms", LongType()),
    StructField("transaction", StringType(), True),
])

# Ler do Kafka
df = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "kafka:9092") \
    .option("subscribe", "liga_sudoers.public.pessoas") \
    .option("startingOffsets", "earliest") \
    .option("failOnDataLoss", "false") \
    .load()

# Parsear JSON
parsed_df = df.select(
    from_json(col("value").cast("string"), debezium_schema).alias("data")
).select("data.*")

# Filtar registros nulos (tombstones)
filtered_df = parsed_df.filter(parsed_df["op"].isNotNull())

# Extrair dados (usar 'after' para insert/update, 'before' para delete)
result_df = filtered_df.select(
    col("op"),
    col("ts_ms"),
    when(col("op").isin("c", "u"), col("after")).otherwise(col("before")).alias("record")
).select(
    col("op"),
    col("ts_ms"),
    col("record.*")
)

# Escrever para MinIO usando Delta Lake
query = result_df \
    .writeStream \
    .format("parquet") \
    .option("path", "s3a://raw/pessoas-cdc/") \
    .option("s3.endpoint", "http://minio:9000") \
    .option("s3.access.key", "sudoers123") \
    .option("s3.secret.key", "sudoers1234") \
    .option("s3.path.style.access", "true") \
    .option("checkpointLocation", "/tmp/spark-checkpoint/pessoas-cdc") \
    .start()

query.awaitTermination()
