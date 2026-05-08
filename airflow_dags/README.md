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


## Estrutura da Fraude

A fraude é usada para treinar o modelo de Machine Learning que será usado para identificar fraudes em tempo real. O ambiente dimensional (DataWarehouse) extrai os dados via ETL (DBT) e popula as informações no nosso Delta Lake para ser usado como ambiente analitico. Esse é um processo mais comum em ambientes de big data.

A fraude é encontrada no geohash (Lat/Lon) da pessoa que fez o pedido. Será considerado fraude qualquer posição geohash fora dos estados de SP, MG e RJ. Ou seja, caso a compra seja de uma posição fora dos estados, deverá ser marcada como fraude. 

A fraude é encontrar no dispositivo da pessoa que fez o pedido. Será considerado fraude qualquer pedido que tenha um dispositivo diferente dos anteriores na hora da compra. Ou seja, se a pessoas comprou anteriormente com Iphone, e agora tentou comprar com um Samsung o pedido será marcado como fraude. 


## Perfil e responsabilidades

Perfis de profissionais e suas responsabilidades no dia a dia dos processos mostrados.
 
  - [Data Engineer](../docs/perfis.md#data-engineer)(Engenheiro de Dados)
  - [Platform Engineer](../docs/perfis.md#plataform-engineer) (Engenheiro de Plataforma)    
  - [BI Analyst](./docs/perfis.md#data_analyst) (Analista de BI)
  - [Data Administrator](./docs/perfis.md#data-administrator) (Administrador de Dados)
  - [DevOps Engineer](./docs/perfis.md#data-engineer) (Engenheiro de DevOps)
  - [Analytics Engineer](./docs/perfis.md#analytics-engineer) (Engenheiro de Analytics)

## Como Executar

### Iniciar Docker pela primeira vez (somente a primeira vez que rodar o processo)
Logando no container para configurar o usuário.
```bash
docker exec -it airflow /bin/bash
```

### Configurar o usuário do Airflow
Criar o usuário no airflow
```bash
airflow users create \
    --username liga_sudoers \
    --firstname Liga \
    --lastname Sudoers \
    --role Admin \
    --email contato@sudoers.com.br \
    --password *liga01
```
## Acessar o Airflow (Sudoers)
### Listas Dags
```bash
airflow dags list
```

Ativar o schedule para rodar as dags conforme agendamento.
```bash
airflow scheduler
```

Para rodar uma DAGs agendada, primeiro vamos tirar ela da pausa.
```bash
airflow dags unpause dbt_run_dag

```

Status da DAG
```bash
airflow dags list-runs -d dbt_run_dag
```

## Acessar o Airflow (Nutela)
Entre na URL abaixo, coloque o usuário e senha e rode a dag.
`localhost:8080`


### Desafio
* Use o script liga_sudoers_streaming.py para gerar novos dados para o fluxo do DBT
* Crie um fluxo via DBT que vá de bronze para gold, e rode-o como uma DAG. Use o fluxo de streaming para esse desafio. 

# Fim da Jornada Engenheiro de Dados
Esse é apenas o início da jornada do engenheiro de dados, porém já é possível entender todos os pontos para a implantação, construção e gerenciamento de um ambiente de Big Data de ponta a ponta. 