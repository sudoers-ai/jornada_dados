# Jornada Engenharia de dados
![Desafio Engenheiro de Dados](../Desafio%20-%20Jornada%20Engenharia%20de%20Dados.png "Desafio Engenheiro de Dados")

Bem-vindo ao Mapa do Engenheiro de Dados, um programa prático e desafiador que recria situações reais enfrentadas por profissionais da área de dados. Neste módulo, você será guiado na construção de uma arquitetura robusta e paralela, que simula um ambiente dinâmico e ininterrupto, tal como ocorre no mercado.

Ao longo do curso, você aprenderá os fundamentos e aplicará técnicas avançadas de modelagem de dados, desenvolvendo consultas transacionais e analíticas em SQL, alcançando um nível de maestria.

# Liga Sudoers - Arquitetura de Big Data

Este repositório visa mostrar o processo trandicional de geração de dados em ambiente transacionais e ETL para ambiente analiticos. Ao subir os containeres serão:
  * 1 ambiente PostgreSQL com modelagem transacional, usando 3 forma normal (3FN)
  * 1 ambiente PostgreSQL com modelagem dimensional. usando star schema. 
  * 1 ambiente com Debezium para CDC.
  * 1 ambiente com Kafka para Streaming.
  * 1 ambiente com Zookeeper para apoio aos serviços.
  * 1 ambiente com Airflow para orquestração de pipelines.
  * 1 ambiente com DBT para Transformação de dados.
  * 1 ambiente com Spark para processamento distribuído.
  * 1 ambiente com MinIO para armazenamento distribuído.
  
  
  Scripts em Python que simulam a entrada de dados:

  * **`airflow_dags/liga_sudoers_streaming.py`** — gera dados de streaming com data atual, cria novos clientes e registra novos pedidos. ~5% viram fraude, para treino do modelo. Roda em laço contínuo:

    ```bash
    cd airflow_dags && python liga_sudoers_streaming.py
    ```

  * **Carga histórica** (datas retroativas, sem criar clientes/produtos novos, ~1% de fraude) — o script `liga_sudoers_historico.py` **não está neste repositório**. Use o gerador canônico do repositório irmão, que faz o mesmo papel e ainda garante que os ids batam entre os dois projetos:

    ```bash
    # em jornada_dados_nosql/
    make lake-oltp args=--limpar
    ```

    Detalhes em [jornada_dados_nosql › integração](https://github.com/sudoers-ai/jornada_dados_nosql/blob/main/integracao/README.md).

  [Vídeo Explicativo](https://youtu.be/Kc-mmy8eMcA)


## Perfil e responsabilidades

Perfis de profissionais e suas responsabilidades no dia a dia dos processos mostrados.
 - Data Architect (Arquiteto de Dados)
 - Data Engineer (Engenheiro de Dados)
 - Data Administrator (Administrador de Dados)
 - DevOps Engineer (Engenheiro de DevOps)


## 📌 Melhor Estratégia para Ingestão do CDC no Data Lake

A melhor estratégia depende dos requisitos de latência, complexidade e custo computacional. Abaixo, um comparativo das abordagens discutidas:

| Estratégia  | Latência  | Complexidade | Custo Computacional |
|------------|----------|-------------|----------------------|
| **Spark Structured Streaming + Delta Lake** | Baixa (quase real-time) | Alta | Alto |
| **Airflow + Batch ETL** | Média (5 min ou mais) | Média | Médio |
| **Kafka Connect + MinIO Sink** | Baixa (quase real-time) | Baixa | Baixo |

### 🔹 **Resumo das Opções**
1. **Spark Structured Streaming + Delta Lake**  
   - 🏆 Melhor para **baixa latência** e **consistência ACID** no Data Lake.
   - 🚀 **Vantagem:** Permite **time travel** e transações ACID.  
   - ⚠ **Desvantagem:** Exige mais recursos de processamento.

2. **Airflow + Batch ETL**  
   - 🏗️ Melhor para **processamento em lotes**, mais fácil de monitorar.  
   - 🚀 **Vantagem:** **Menor custo computacional** e simples de orquestrar.  
   - ⚠ **Desvantagem:** **Latência maior**, não ideal para real-time.

3. **Kafka Connect + MinIO Sink**  
   - 🔄 Melhor para **ingestão contínua sem código adicional**.  
   - 🚀 **Vantagem:** **Fácil de configurar** e gerenciar.  
   - ⚠ **Desvantagem:** Não permite **transformações complexas** antes da gravação.

### 🔥 **Qual escolher?**
- Se **precisa de baixa latência** e **confiabilidade** → **Spark Structured Streaming + Delta Lake** ✅
- Se **preferir simplicidade e menor custo** → **Kafka Connect + MinIO Sink** ✅
- Se **lotes são suficientes e quer controle via Airflow** → **Airflow + Batch ETL** ✅

### Pegando os dados do Log de Transação (WAL)


```bash
docker exec -it debezium /bin/bash
```

```bash
cd /home/
curl -X POST -H "Content-Type: application/json" --data @minio-sink.json http://debezium:8083/connectors
```


curl -X POST -H "Content-Type: application/json" --data '  {
    "name": "minio-sink-connector",
    "config": {
      "connector.class": "io.confluent.connect.s3.S3SinkConnector",
      "tasks.max": "1",
      "topics": "liga_sudoers.public.pessoas",
      "s3.bucket.name": "raw",
      "s3.region": "us-east-1",
      "s3.endpoint": "http://minio:9000",
      "s3.access.key": "sudoers123",
      "s3.secret.key": "sudoers1234",
      "format.class": "io.confluent.connect.s3.format.json.JsonFormat",
      "storage.class": "io.confluent.connect.s3.storage.S3Storage",
      "flush.size": "10",
      "rotate.interval.ms": "10000"
    }
  }' http://debezium:8083/connectors



## PySpark
Vamos usar o PySpark para trazer os dados 

```bash
docker exec -it spark bash
```

```bash
spark-sql \
  --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" \
  --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog" \
  --conf "spark.hadoop.fs.s3a.access.key=sudoers123" \
  --conf "spark.hadoop.fs.s3a.secret.key=sudoers1234" \
  --conf "spark.hadoop.fs.s3a.endpoint=http://minio:9000" \
  --conf "spark.hadoop.fs.s3a.path.style.access=true" \
  --conf "spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem" \
  --conf "spark.hadoop.fs.s3a.connection.ssl.enabled=false"
  --packages io.delta:delta-spark_2.12:3.2.1,io.delta:delta-storage-3.2.1
```


# Continue no dbt_project/README.md


# pySpark

from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("MinIO Test") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
    .config("fs.s3a.access.key", "sudoers123") \
    .config("fs.s3a.secret.key", "sudoers1234") \
    .config("fs.s3a.endpoint", "http://minio:9000") \
    .config("fs.s3a.path.style.access", "true") \
    .config("fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .config("fs.s3a.connection.ssl.enabled", "false") \
    .getOrCreate()

df = spark.read.option("header", "true").csv(f"s3a://raiz/organizations/organizations.csv")

# Criar DataFrame e salvar no MinIO
data = [("Alice", 34), ("Bob", 45)]
df = spark.createDataFrame(data, ["Name", "Age"])
df.write.mode("delta").parquet("s3a://raiz/test_output-delta/")
