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



# Streaming

## Configurando o PostgreSQL

### Pegando os dados do Log de Transação (WAL)


```bash
docker exec -it postgres_oltp /bin/bash
```

```bash
psql -U sudoers -d liga_sudoers 
```

```bash
CREATE PUBLICATION pessoas_pub FOR TABLE pessoas;

CREATE USER debezium WITH REPLICATION PASSWORD 'sudoers';
GRANT SELECT ON pessoas TO debezium;
```

## Configurando o Debezium

### Cadastrando os conectores do Debezium->Kafka
```bash
docker exec -it debezium curl -s http://localhost:8083/
docker exec -it debezium curl -s http://localhost:8083/connectors
docker exec -it debezium curl -s http://localhost:8083/connector-plugins

```


```bash
docker exec -it debezium /bin/bash


cd /home

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" --data @debezium-postgres.json http://debezium:8083/connectors/

curl -s http://debezium:8083/connectors/postgres-connector-pessoas/status

```

### Visualizando os tópicos criados
```bash
kafka-topics.sh --bootstrap-server kafka:9092 --list
```

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


## Enviando os dados do Kafka para o Data Lake (MinIO)
Usando o Kafka Connect vamos criar um connector que traz os dados do Kafka e os envia para o Minio. 

### Cadastrando os conectores do Kafka->Minio(S3)
```bash
curl -X POST -H "Content-Type: application/json" --data @minio-sink.json http://debezium:8083/connectors

curl -s http://debezium:8083/connectors/minio-sink-connector/status
```

### Lendo os dados da tabela pessoas no Kafka
Podemos inspecionar as mensagens em tempo real no tópico `liga_sudoers.public.pessoas` usando o `kafka-console-consumer`. Isso nos permite ver exatamente o JSON de CDC gerado pelo Debezium, com os dados da tabela pessoas.

```bash
docker exec -it kafka /bin/kafka-console-consumer --bootstrap-server kafka:9092 --topic liga_sudoers.public.pessoas --from-beginning
```



### Visualizando Mutações de Dados (Update e Delete na prática!)
Para provar o poder do Debezium capturando eventos além da simples inserção, criamos um script que altera os dados da tabela `pessoas` em tempo real. Ele simula clientes mudando de nome e contas sendo encerradas.

No seu terminal (fora do Docker), execute o comando abaixo para iniciar o gerador:
```bash
python airflow_dags/liga_sudoers_cdc_demo.py
```
*(Deixe-o rodando e siga para o próximo passo no terminal do Spark SQL para ver as operações `"u"` (update) e `"d"` (delete) chegando no seu Data Lake!)*

### Lendo os dados gerados pelo CDC no Data Lake via Spark SQL
Diferente de um banco tradicional (Schema on Write), o Spark trabalha com o conceito de Schema on Read. Quando criamos uma External Table apontando para o MinIO, o Spark infere automaticamente a estrutura do JSON e mapeia as pastas (`year=.../month=...`) como partições virtuais da tabela.

1. Abra o terminal do Spark:
```bash
docker exec -it spark bash
spark-sql
```

2. Crie a tabela apontando para o MinIO e descubra as partições:
```sql
CREATE DATABASE IF NOT EXISTS raw;

CREATE TABLE raw.pessoas_cdc
USING JSON
LOCATION 's3a://raw/topics/liga_sudoers.public.pessoas/';

-- Comando para o Spark descobrir as pastas year/month/day
MSCK REPAIR TABLE raw.pessoas_cdc;
```

3. Consulte os dados entendendo o formato do Debezium:
O Debezium empacota a linha em um envelope. A operação (insert, update) fica na coluna `op` (`r` para leitura inicial, `c` para insert, `u` para update), e os dados da tabela em si ficam dentro de um objeto chamado `after` (ou `before`). O Spark mapeia isso de forma nativa como um Struct, permitindo acessar `after.coluna`.

```sql
SELECT 
    op as operacao, 
    after.id,
    after.nome, 
    after.sexo,
    after.dt_nasc,
    after.created_at,
    after.updated_at,
    year, month, day
FROM raw.pessoas_cdc 
LIMIT 10;
```

### Desafio
* Veja o arquivo minio-sink.json e reveja este README para entender como criar um novo tópico para outras tabelas. Faça isso para as tabelas que achar válidas serem capturadas (dica: auditoria_pedidos).


## Kafka (Comandos de apoio)
```bash
curl -X DELETE http://debezium:8083/connectors/minio-sink-connector
curl -X POST http://debezium:8083/connectors/minio-sink-connector/restart
```


# Continue no kafka/README.md