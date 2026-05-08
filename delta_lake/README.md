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
  - [Platform Engineer](../docs/perfis.md#plataform-engineer) (Engenheiro de Plataforma)  
  - [Data Administrator](../docs/perfis.md#data-administrator) (Administrador de Dados)
  - [DevOps Engineer](../docs/perfis.md#devops-engineer) (Engenheiro de DevOps)


# Modo Old School
Antes de avançarmos para os métodos mais atuais, vamos entender o passado. Começando pelo Hadoop e Hive. 

## O passado

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

O Sqoop (SQL to Hadoop) surgiu dessa necessidade de enviar arquivos para o armazenamento distribuído.


## Spark-SQL
Vamos usar o Minio como armazenamento no lugar do HDFS (Hadoop) e o Spark-SQL no lugar do Hive, porém os comandos são bem parecidos.

Quando o MapReduce ainda era a única opção de processamento, o Facebook criou o Hive e levou o SQL para dentro do DataLake.

```bash
docker exec -it spark bash
```

```bash
spark-sql
```

### Criando tabelas
Vamos fazer a federação com o PostgreSQL para integração de dados ficar mais simples.  
```bash
spark-sql (default)> CREATE SCHEMA olap;
spark-sql (default)> USE olap;
spark-sql (olap)> CREATE TABLE dim_pessoas
USING jdbc
OPTIONS (
    url "jdbc:postgresql://postgres_olap:5432/liga_sudoers_dw",
    driver "org.postgresql.Driver",
    dbtable "dim_pessoas",
    user "sudoers",
    password "sudoers"
);

spark-sql (olap)> CREATE TABLE dim_produtos
USING jdbc
OPTIONS (
    url "jdbc:postgresql://postgres_olap:5432/liga_sudoers_dw",
    driver "org.postgresql.Driver",
    dbtable "dim_produtos",
    user "sudoers",
    password "sudoers"
);
```

### Vendo os dados da tabela federada
Vamos criar algumas tabelas no modo old. 
```bash
spark-sql (olap)> USE raw;

spark-sql (raw)> SELECT * FROM dim_pessoas;

spark-sql (raw)> SELECT dp.nome, df.nome 
                    FROM olap.dim_pessoas df 
                      INNER JOIN dim_pessoas dp 
                    ON dp.sk_pessoa = df.sk_pessoa 
                  LIMIT 10;
```


### Criando a dim_produtos usando a tabela federada
```bash
spark-sql (raw)> CREATE TABLE dim_produtos (
    sk_produto STRING,
    id STRING,
    cat_desc STRING,
    descricao STRING,
    created_at STRING,
    updated_at STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE
LOCATION 's3a://raw/dim_produtos/';

spark-sql (raw)> INSERT OVERWRITE TABLE dim_produtos SELECT * FROM olap.dim_produtos;
```

### Criando a fato_pedidos usando a tabela federada e particionando
```bash
spark-sql (raw)> CREATE TABLE olap.fato_pedidos
USING jdbc
OPTIONS (
    url "jdbc:postgresql://postgres_olap:5432/liga_sudoers_dw",
    driver "org.postgresql.Driver",
    dbtable "fato_pedidos",
    user "sudoers",
    password "sudoers"
);

spark-sql (raw)> DESCRIBE olap.fato_pedidos;

spark-sql (raw)> SELECT * FROM olap.fato_pedidos LIMIT 10;

spark-sql (raw)> CREATE TABLE fato_pedidos (
    sk_id STRING,
    id_pedido STRING,
    sk_pessoa STRING,
    sk_produto STRING,
    dispositivo STRING,
    geohash STRING,
    telefone STRING,
    qtde STRING, 
    valor_unit STRING, 
    total STRING
)
PARTITIONED BY (dt_venda STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE
LOCATION 's3a://raw/fato_pedidos/';


spark-sql (raw)> set hive.exec.dynamic.partition.mode=nonstrict;

spark-sql (raw)> INSERT OVERWRITE TABLE fato_pedidos PARTITION (dt_venda) 
      SELECT sk_id, id_pedido, sk_pessoa, sk_produto, dispositivo, geohash, telefone, qtde, valor_unit, total, CAST(CAST(dt_venda as DATE) as STRING) FROM olap.fato_pedidos; -- WHERE dt_venda = '2024-01-27';


spark-sql (raw)> SHOW PARTITIONS fato_pedidos;
```

# Datalake
## Movendo entre as zonas do Datalake

Fluxo Entre as Zonas

    Raw → Trusted:
        Os dados são validados, normalizados e limpos.

```bash
spark-sql (raw)> CREATE SCHEMA trusted;
spark-sql (raw)> USE trusted;
spark-sql (trusted)> CREATE TABLE dim_pessoas STORED as parquet LOCATION 's3a://trusted/dim_pessoas/' AS SELECT CAST(sk_pessoa as INT) as sk_pessoa, CAST(id as bigint) as id, nome, sexo, CAST(dt_nasc as DATE) as dt_nasc FROM raw.dim_pessoas;

spark-sql (trusted)> CREATE TABLE dim_produtos STORED as parquet LOCATION 's3a://trusted/dim_produtos/' AS SELECT CAST(sk_produto as INT) as sk_produto, id, cat_desc, descricao FROM raw.dim_produtos;

spark-sql (trusted)> CREATE TABLE fato_pedidos PARTITIONED BY (dt_venda) STORED as parquet LOCATION 's3a://trusted/fato_pedidos/' AS SELECT CAST(sk_id as INT) as sk_id, CAST(id_pedido as INT) as id_pedido, CAST(sk_pessoa as INT) as sk_pessoa, CAST(sk_produto as INT) as sk_produto, dispositivo, geohash, telefone, CAST(qtde as INT) as qtde, CAST(valor_unit as decimal(10,2)) as valor_unit, CAST(total as decimal(10,2)) as total, CAST(dt_venda as DATE) as dt_venda FROM raw.fato_pedidos;
```

Trusted → Refined:
        Os dados são transformados, agregados e otimizados para análises avançadas.

```bash
spark-sql (trusted)> CREATE SCHEMA refined;
spark-sql (trusted)> USE refined;
spark-sql (refined)> CREATE TABLE itens_by_person PARTITIONED BY (dt_venda) STORED as parquet LOCATION 's3a://refined/itens_by_person/' 
AS SELECT dp.nome, dp.sexo, dp.dt_nasc, dpr.cat_desc, dpr.descricao, fp.id_pedido, fp.dt_venda, fp.dispositivo, fp.geohash, COALESCE(valor_unit, 0 ) as total
    FROM trusted.fato_pedidos fp
        INNER JOIN trusted.dim_produtos dpr ON dpr.sk_produto = fp.sk_produto
        INNER JOIN trusted.dim_pessoas dp ON dp.sk_pessoa = fp.sk_pessoa    
    ORDER BY 6 desc, 1, 2, 3, 4, 5, 7, 8;
```

## Quero fazer DML
```bash
spark-sql (refined)> USE trusted;
spark-sql (trusted)> DELETE FROM dim_pessoas WHERE id is NULL;
spark-sql (trusted)> UPDATE dim_pessoas set id = 0  WHERE id is NULL;
```

### Não consigo, pois o parquet não permite Update/Delete.

```bash
spark-sql (trusted)> INSERT INTO dim_pessoas VALUES (0,0, 'vazio', '', NULL);
spark-sql (trusted)> SELECT * FROM dim_pessoas WHERE id is NULL or id = 0;
```

### Resolvendo o problema do DELETE

```bash
spark-sql (trusted)> SELECT * FROM dim_pessoas ORDER BY 1; 

spark-sql (trusted)> CREATE TABLE ttl_dim_pessoas(version int, dt_exec timestamp, sk_pessoa int, id bigint, nome string, sexo string, dt_nasc string, cmd string) STORED AS parquet; 

spark-sql (trusted)> INSERT INTO ttl_dim_pessoas SELECT 1, now(), *, 'delete' FROM dim_pessoas WHERE id IS NULL;

spark-sql (trusted)> SELECT * FROM dim_pessoas EXCEPT SELECT sk_pessoa, id, nome, sexo, dt_nasc FROM ttl_dim_pessoas ORDER BY 1;

```

### Resolvendo o problema do UPDATE

```bash
spark-sql (trusted)> SELECT * FROM dim_pessoas WHERE id = 0;


spark-sql (trusted)> INSERT INTO ttl_dim_pessoas SELECT 2, now(), *, 'delete' FROM dim_pessoas WHERE id = 0;
spark-sql (trusted)> INSERT INTO dim_pessoas SELECT 0, 11984821841, 'Liga Sudoers', 'M', CAST('2025-01-01' as DATE);
spark-sql (trusted)> INSERT INTO ttl_dim_pessoas SELECT 2, now(), 0, 11984821841, 'Liga Sudoers', 'M', CAST('2025-01-01' as DATE), 'insert';

spark-sql (trusted)> SELECT * FROM dim_pessoas EXCEPT SELECT sk_pessoa, id, nome, sexo, dt_nasc FROM ttl_dim_pessoas WHERE cmd = 'delete' ORDER BY 1;

```

### Ativando o TimeTravel
Vamos supor que eu queira executar um UPDATE nos clientes adicionando o sobrenome Sudoers. 

```bash
spark-sql (trusted)> INSERT INTO ttl_dim_pessoas SELECT 3, now(), *, 'delete' FROM dim_pessoas WHERE sk_pessoa IN (2, 4, 6, 8);
spark-sql (trusted)> INSERT INTO ttl_dim_pessoas SELECT 3, now(), sk_pessoa, id, nome || ' - Sudoers', sexo, dt_nasc, 'insert' from dim_pessoas WHERE sk_pessoa IN (2, 4, 6, 8);
spark-sql (trusted)> INSERT INTO dim_pessoas SELECT sk_pessoa, id, nome || ' - Sudoers' , sexo, dt_nasc from dim_pessoas WHERE sk_pessoa IN (2, 4, 6, 8);

spark-sql (trusted)> SELECT * FROM dim_pessoas EXCEPT SELECT sk_pessoa, id, nome, sexo, dt_nasc FROM ttl_dim_pessoas WHERE cmd = 'delete' ORDER BY 1;

spark-sql (trusted)> SELECT * FROM dim_pessoas EXCEPT SELECT sk_pessoa, id, nome, sexo, dt_nasc FROM ttl_dim_pessoas  WHERE (cmd = 'delete' AND version <= 2) OR (version > 2 AND cmd = 'insert') ORDER BY 1;
```

### Vacuum

```bash
spark-sql (trusted)> CREATE TABLE dim_pessoas_v2 SELECT * FROM dim_pessoas EXCEPT SELECT sk_pessoa, id, nome, sexo, dt_nasc FROM ttl_dim_pessoas  WHERE (cmd = 'delete' AND version <= 2) OR (version > 2 AND cmd = 'insert') ORDER BY 1;
```

## Delta Lake
```bash
spark-sql (trusted)> CREATE TABLE dim_pessoas_delta USING delta LOCATION 's3a://trusted/dim_pessoas_delta/' AS SELECT CAST(sk_pessoa as INT) as sk_pessoa, CAST(id as bigint) as id, nome, sexo, CAST(dt_nasc as DATE) as dt_nasc FROM raw.dim_pessoas;

spark-sql (trusted)> CREATE TABLE dim_produtos_delta USING delta LOCATION 's3a://trusted/dim_produtos_delta/' AS SELECT CAST(sk_produto as INT) as sk_produto, id, cat_desc, descricao FROM raw.dim_produtos;

spark-sql (trusted)> CREATE TABLE fato_pedidos_delta USING delta PARTITIONED BY (dt_venda) LOCATION 's3a://trusted/fato_pedidos_delta/' AS SELECT CAST(sk_id as INT) as sk_id, CAST(id_pedido as INT) as id_pedido, CAST(sk_pessoa as INT) as sk_pessoa, CAST(sk_produto as INT) as sk_produto, dispositivo, geohash, telefone, CAST(qtde as INT) as qtde, CAST(valor_unit as decimal(10,2)) as valor_unit, CAST(total as decimal(10,2)) as total, CAST(dt_venda as DATE) as dt_venda FROM raw.fato_pedidos;
```

### Fazendo DML
```bash
spark-sql (trusted)> INSERT INTO dim_pessoas_delta SELECT sk_pessoa, id, nome || ' - Sudoers' , sexo, dt_nasc from dim_pessoas WHERE sk_pessoa IN (2, 4, 6, 8);
spark-sql (trusted)> UPDATE dim_pessoas_delta SET nome = nome || ' - UPDATE';
spark-sql (trusted)> SELECT * FROM dim_pessoas_delta;

spark-sql (trusted)> DELETE FROM dim_pessoas_delta;
spark-sql (trusted)> SELECT * FROM dim_pessoas_delta;
```

### TimeTravel
```bash
spark-sql (trusted)> DESCRIBE HISTORY dim_pessoas_delta;

spark-sql (trusted)> SELECT * FROM dim_pessoas_delta VERSION AS OF 1;

spark-sql (trusted)> RESTORE TABLE dim_pessoas_delta TO VERSION AS OF 1;

spark-sql (trusted)> SELECT * FROM dim_pessoas_delta;
```

### Vacuum
```bash
spark-sql (trusted)> VACUUM dim_pessoas_delta;
```

# Continue no debezium/README.md