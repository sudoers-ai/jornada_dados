#!/bin/bash


cp  /data/jars/*.jar /opt/bitnami/spark/jars/

echo 'Moveu Jars'

# Inicializa o Spark
/opt/bitnami/scripts/spark/run.sh


 #/opt/bitnami/spark/sbin/start-thriftserver.sh --master spark://spark:7077 --conf spark.sql.catalogImplementation=hive

#!/bin/bash
#export PYSPARK_SUBMIT_ARGS="--packages io.delta:delta-core_2.12:2.4.0,io.delta:delta-storage:2.4.0 --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog pyspark-shell"
