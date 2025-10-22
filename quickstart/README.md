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
  
  
  Dentro do repositório teremos os scripts em Python que irão simular a entrada de dados:
  * liga_sudoers_historico.py - Gera dados históricos com pedidos com data retroativas, não gera novos produtos nem novos clientes. Gera 1% de dados que serão considerados fraude para treinamento do modelo. 
  * liga_sudoers_streaming.py - Gera dados streamind com pedidos com data atual, gera novos clientes e registra novos pedidos. Gera 5% de dados que serão considerados fraude para treinamento do modelo. 

  [Vídeo Explicativo](https://youtu.be/Kc-mmy8eMcA)


## Perfil e responsabilidades

Perfis de profissionais e suas responsabilidades no dia a dia dos processos mostrados. 
  - [Data Architect](../docs/perfis.md#data-architect) (Arquiteto de Dados) 
  - [Data Engineer](../docs/perfis.md#data-engineer)(Engenheiro de Dados)
  - [Data Scientist](../docs/perfis.md#data-scientist) (Cientista de Dados)
  - [Platform Engineer](../docs/perfis.md#plataform-engineer) (Engenheiro de Plataforma)  
  - [Data Administrator](../docs/perfis.md#data-administrator) (Administrador de Dados)
  - [Analytics Engineer](../docs/perfis.md#analytics-engineer) (Engenheiro de Analytics)
 

# Modo Old School
Antes de avançarmos para os métodos mais atuais, vamos entender o passado. Começando pelo Hadoop e Hive. 

Hadoop é um FileSystem Distribuído, ele garante a disponibilidade do arquivo pois o mesmo estará distribuído em várias outras máquinas.

## O passado

Quando o Big Data nasceu, não era usando SQL para se extrair os dados.

```bash
 grep -E ';M;' quickstart/dim_pessoas.csv

 cat quickstart/dim_pessoas.csv | grep -oE 'M|F' | sort | uniq -c

 awk -F';' 'NR>1 {split($5, d, "-"); idade=2025-d[1]; if (idade >= 18 && idade <= 40) print $4}' quickstart/dim_pessoas.csv | sort | uniq -c

 awk -F';' 'NR>1 {split($5, d, "-"); idade=2025-d[1]; if (idade >= 18 && idade <= 40) print $0}' quickstart/dim_pessoas.csv
```

## MapReduce 

Ver arquivo `quickstart/mapreduce.java`

## HIVE

O Hive foi criado usando a linguagem HQL, ele veio para ser parecido com o SQL.


### Movendo dados do DW para dentro do HDFS
Vamos usar o MINIO no luhar do HDFS, mas a ideia é a mesma. Ser um armazenamento distribuído.

```bash
 docker exec -it postgres_olap bash
```

Iremos extrair os dados do nosso ambiente DW e enviaremos para o MINIO.

```bash
psql -U sudoers -d liga_sudoers_dw  -c 'COPY (SELECT * FROM dim_pessoas) TO STDOUT WITH (FORMAT csv, HEADER true, DELIMITER ";");' > /tmp/dim_pessoas.csv
```

pass: `sudoers`


Vamos jogar o pessoal.csv para dentro do armazenamento distribuído.

```bash
docker exec -it minio bash
```

```bash
mc cp /home/dim_pessoas.csv  local/raw/dim_pessoas/dim_pessoas.csv
```


## Spark-SQL
Vamos usar o Minio como armazenamento no lugar do HDFS (Hadoop) e o Spark-SQL no lugar do Hive, porém os comandos são bem parecidos.

```bash
docker exec -it spark bash
```


```bash
spark-sql
```

### Criando tabelas
Vamos criar algumas tabelas no modo old. 
```bash
spark-sql (default)> CREATE SCHEMA raw;
spark-sql (default)> use raw;
spark-sql (raw)> CREATE EXTERNAL TABLE dim_pessoas (
    sk_pessoa STRING,
    id STRING,
    nome STRING, 
    sexo STRING, 
    dt_nasc STRING,
    created_at STRING,
    updated_at STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE
LOCATION 's3a://raw/dim_pessoas/'
TBLPROPERTIES ("skip.header.line.count"="1");
```

### Vendo os dados da tabela
```bash
spark-sql (raw)> SELECT * FROM dim_pessoas;
```

### Desafio
* Insira arquivos .log e tente usar REGEX para extrair as informações de cada coluna.

# Continue no delta_lake/README.md