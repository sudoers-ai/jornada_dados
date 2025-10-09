# Jornada Engenharia de dados
![Desafio Engenheiro de Dados](Desafio%20-%20Jornada%20Engenharia%20de%20Dados.png "Desafio Engenheiro de Dados")

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
  * liga_sudoers_streaming.py - Gera dados streaming com pedidos com data atual, gera novos clientes e registra novos pedidos. Gera 5% de dados que serão considerados fraude para treinamento do modelo. 

  [Vídeo Explicativo](https://youtu.be/Kc-mmy8eMcA)


## Estrutura da Fraude

A fraude é usada para treinar o modelo de Machine Learning que será usado para identificar fraudes em tempo real. O ambiente dimensional (DataWarehouse) extrai os dados via ETL (DBT) e popula as informações no nosso Delta Lake para ser usado como ambiente analitico. Esse é um processo mais comum em ambientes de big data.

A fraude é encontrada no geohash (Lat/Lon) da pessoa que fez o pedido. Será considerado fraude qualquer posição geohash fora dos estados de SP, MG e RJ. Ou seja, caso a compra seja de uma posição fora dos estados, deverá ser marcada como fraude. 

A fraude é encontrar no dispositivo da pessoa que fez o pedido. Será considerado fraude qualquer pedido que tenha um dispositivo diferente dos anteriores na hora da compra. Ou seja, se a pessoa comprou anteriormente com Iphone, e agora tentou comprar com um Samsung o pedido será marcado como fraude. 

## Estrutura do Projeto
```bash
.
├── airflow_dags
├── dbt_project
│   ├── dbt_project.yml
│   ├── logs
│   │   └── dbt.log
│   ├── models
│   │   └── example_model.sql
│   └── profiles.yml
├── debezium-init
│   ├── 01_enable_replication.sql
│   ├── connect-log4j.properties
│   └── postgres-connector.json
├── delta_lake
│   ├── entrypoint.sh
│   ├── jars
│   │   ├── delta-core_2.12-2.4.0.jar
│   │   └── delta-storage-2.4.0.jar
│   └── pyspark
├── docker-compose.yml
├── kafka
│   └── server.properties
├── postgresql-init
│   └── 02_create_airflow_db.sql
├── quickstart
│   ├── organizations.csv
│   └── people.zip
└── README.md
```
## Perfis profissionais atuantes

Perfis de profissionais no dia a dia dos processos mostrados.
 - [Data Architect](./docs/perfis.md#data-architect) (Arquiteto de Dados) 
 - [Data Engineer](./docs/perfis.md#data-engineer)(Engenheiro de Dados)
 - [Data Scientist](./docs/perfis.md#data-scientist) (Cientista de Dados)
 - [Platform Engineer](./docs/perfis.md#plataform-engineer) (Engenheiro de Plataforma)
 - [Machine Learning Engineer - MLOps](./docs/perfis.md#machine-learning-engineer) (Engenheiro de Machine Learning - MLOps)
 - [BI Analyst](./docs/perfis.md#data_analyst) (Analista de BI)
 - [Data Administrator](./docs/perfis.md#data-administrator) (Administrador de Dados)
 - [DevOps Engineer](./docs/perfis.md#data-engineer) (Engenheiro de DevOps)
 - [Analytics Engineer](./docs/perfis.md#analytics-engineer) (Engenheiro de Analytics)


## Pré-requisitos

- Python 3.x
- Docker e Docker Compose
- Biblioteca `psycopg2`
- Biblioteca `Faker`


## Antes de Executar


### Instalação do Docker Compose
```bash
sudo apt update
sudo apt install docker-compose-plugin awscli
```

### Verificação da Versão (opcional)
```bash
docker compose version
```


## Como Executar

### Iniciar Docker pela primeira vez (somente a primeira vez que rodar o processo)
```bash
docker compose up --build
```

### Iniciar Docker pela segunda vez
```bash
docker compose up 
```

### Parar o Docker Compose caso esteja rodando
```bash
docker compose stop
```

# Modo Terminal 

### Iniciando o armazenamento distribuído com MinIO:

Logando no container para configurar os buckets.
```bash
docker exec -it minio sh
```


### Configurar o MINIO
Adicionar o alias para acessar ao ambiente. 
```bash
mc alias set local http://minio:9000 sudoers123 sudoers1234
```


### Crie um bucket para armazenar os dados:
Criar os buckets que irão servir para armazenar os dados. Criaremos as camadas raw, trusted e refined para o Data Lake.
```bash
mc mb local/raw
mc mb local/trusted
mc mb local/refined
```


### Copiar arquivo para dentro do MINIO
```bash
mc cp /home/dim_pessoas.csv  local/raw/dim_pessoas/dim_pessoas.csv
```

### Sete o bucket para que sejam públicos.
```bash
mc anonymous set public local/raw
mc anonymous set public local/trusted
mc anonymous set public local/refined
```

### Utilizar o AWS CLI (Opcional)
O MinIO é compatível com o protocolo S3, então você também pode usar o aws-cli para listar e visualizar arquivos.
Faça a configuração no host.

    Configure o aws-cli para o MinIO:
        Configure o perfil para o MinIO:

```bash
 PYTHONNOUSERSITE=1 aws configure --profile minio
 ou 
 aws configure --profile minio

    Access Key: sudoers123
    Secret Key: sudoers1234
    Default region: Deixe vazio
    Default output: json
```

Liste os buckets:

```bash
PYTHONNOUSERSITE=1 aws s3 ls --endpoint-url http://localhost:9000 --profile minio
ou 
aws s3 ls --endpoint-url http://localhost:9000 --profile minio

# Liste os arquivos em um bucket:

PYTHONNOUSERSITE=1 aws s3 ls s3://raw --endpoint-url http://localhost:9000 --profile minio
ou 
aws s3 ls s3://raw --endpoint-url http://localhost:9000 --profile minio
```



# Visualizar UI
Abra o browser na sua máquina e acesso a url:`http://localhost:9000`

```bash
user:sudoers123
pass:sudoers1234
```

## Modo Nutela
Via UI faça a criação de um bucket com nome `staging`



# Continue no quickstart/README.md