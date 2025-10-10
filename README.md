Perfeito, Vinícius! Reescrevi o seu README para ficar mais atrativo, direto e “mão na massa” para quem vai replicar o passo a passo. Mantive **todo o código exatamente como você definiu** (sem alterações nos blocos). Incluí orientações práticas, checklists, dicas de troubleshooting e um fluxo de validação para o aluno saber quando “deu certo”.

---

# 🚀 Jornada Engenharia de Dados — Mapa do Engenheiro de Dados

![Desafio Engenheiro de Dados](Desafio%20-%20Jornada%20Engenharia%20de%20Dados.png "Desafio Engenheiro de Dados")

Bem-vindo ao **Mapa do Engenheiro de Dados**: um programa 100% prático que simula cenários reais do mercado. Aqui você vai subir uma **arquitetura moderna** (transacional, CDC, streaming, DW e lake) e executar **pipelines ponta a ponta**, do **OLTP** ao **Delta Lake**, com orquestração e transformação.

Ao final, você terá:

* Uma stack completa rodando em containers;
* Dados históricos + streaming chegando continuamente;
* Camadas **raw → trusted → refined** no MinIO (S3 compatible);
* DW dimensional para analytics + base para treinar um modelo antifraude.

---

## 🧩 O que você vai construir

### Liga Sudoers — Arquitetura de Big Data

Este repositório demonstra o fluxo tradicional **OLTP → CDC → ETL/ELT → DW → Data Lake (Delta)** com orquestração e streaming:

* PostgreSQL (3FN) — base transacional
* PostgreSQL (Star Schema) — DW dimensional
* Debezium — CDC (captura de alterações)
* Kafka + Zookeeper — fila/stream
* Airflow — orquestração de pipelines
* DBT — transformação de dados
* Spark — processamento distribuído
* MinIO — armazenamento de dados em camadas (raw/trusted/refined)

**Geradores de dados (Python):**

* `liga_sudoers_historico.py` — cria histórico (datas retroativas), **1%** de fraudes, sem novos clientes/produtos.
* `liga_sudoers_streaming.py` — cria streaming (data atual), **5%** de fraudes, com novos clientes/pedidos.

[Vídeo Explicativo](https://youtu.be/Kc-mmy8eMcA)

---

## 🕵️‍♂️ Como detectamos fraude (visão geral)

* **Localização (geohash)**: compras **fora de SP, MG e RJ** são marcadas como fraude.
* **Dispositivo**: se o cliente mudar o device (ex.: antes iPhone, agora Samsung), o pedido é marcado como suspeito.

O DW extrai, transforma (DBT) e **povoa o Delta Lake**, base para analytics e treino de modelos de ML (detecção em tempo quase real).

---

## 🗂️ Estrutura do projeto (para se localizar)

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

---

## 👩‍💻 Quem faz o quê (perfis atuantes)

* [Data Architect](./docs/perfis.md#data-architect)
* [Data Engineer](./docs/perfis.md#data-engineer)
* [Data Scientist](./docs/perfis.md#data-scientist)
* [Platform Engineer](./docs/perfis.md#plataform-engineer)
* [Machine Learning Engineer / MLOps](./docs/perfis.md#machine-learning-engineer)
* [BI Analyst](./docs/perfis.md#data_analyst)
* [Data Administrator](./docs/perfis.md#data-administrator)
* [DevOps Engineer](./docs/perfis.md#data-engineer)
* [Analytics Engineer](./docs/perfis.md#analytics-engineer)

> **Dica**: ao longo do desafio, tente enxergar suas tarefas sob cada um desses chapéus. Isso acelera sua visão de arquitetura e operação.

---

## ✅ Pré-requisitos (checklist rápido)

* [ ] **Python 3.x** instalado
* [ ] **Docker** e **Docker Compose** instalados
* [ ] Bibliotecas Python: `psycopg2`, `Faker`
* [ ] Porta **9000** livre (MinIO UI)

> No Windows, use WSL2; no Mac, certifique-se de dar permissão de recursos (CPU/RAM) no Docker Desktop.

---

## ⚙️ Instalação do Docker Compose

```bash
sudo apt update
sudo apt install docker-compose-plugin awscli
```

**Verificar versão (opcional):**

```bash
docker compose version
```

---

## ▶️ Como executar (primeiros passos em 10 minutos)

**Primeira execução (build completo):**

```bash
docker compose up --build
```

**Executar novamente (sem rebuild):**

```bash
docker compose up 
```

**Parar tudo:**

```bash
docker compose stop
```

> **Validação rápida:** quando todos os serviços estiverem “healthy”, você já deve conseguir acessar o **MinIO** em `http://localhost:9000`.


## 🖥️ Modo Terminal — MinIO (S3 compatível)

**Entrar no container:**

```bash
docker exec -it minio sh
```

**Configurar alias:**

```bash
mc alias set local http://minio:9000 sudoers123 sudoers1234
```

**Criar buckets (camadas do Data Lake):**

```bash
mc mb local/raw
mc mb local/trusted
mc mb local/refined
```

**Copiar arquivo para o MinIO:**

```bash
mc cp /home/dim_pessoas.csv  local/raw/dim_pessoas/dim_pessoas.csv
```

**Deixar buckets públicos:**

```bash
mc anonymous set public local/raw
mc anonymous set public local/trusted
mc anonymous set public local/refined
```

## 🧰 (Opcional) Usando AWS CLI com MinIO

**Configurar perfil:**

```bash
 PYTHONNOUSERSITE=1 aws configure --profile minio
 ou 
 aws configure --profile minio
```

```
Access Key: sudoers123
Secret Key: sudoers1234
Default region: (deixe vazio)
Default output: json
```

**Listar buckets:**

```bash
PYTHONNOUSERSITE=1 aws s3 ls --endpoint-url http://localhost:9000 --profile minio
ou 
aws s3 ls --endpoint-url http://localhost:9000 --profile minio
```

**Listar arquivos do bucket `raw`:**

```bash
PYTHONNOUSERSITE=1 aws s3 ls s3://raw --endpoint-url http://localhost:9000 --profile minio
ou 
aws s3 ls s3://raw --endpoint-url http://localhost:9000 --profile minio
```

---

## 🌐 Visualizar a UI do MinIO

Abra o navegador e acesse: `http://localhost:9000`

```bash
user:sudoers123
pass:sudoers1234
```

**Modo Nutela (via UI):** crie um bucket chamado `staging`.

## 🧭 Fluxo recomendado de estudo (passo a passo)

1. **Suba a stack** (`docker compose up --build`).
2. **Valide o MinIO** (UI e buckets criados).
3. **Rode o gerador histórico** (`liga_sudoers_historico.py`) para popular base inicial.
4. **Ative CDC (Debezium)** e confirme publicação no **Kafka**.
5. **Execute o streaming** (`liga_sudoers_streaming.py`) e valide novos eventos.
6. **Rode DBT** para transformar e carregar o DW.
7. **Consuma no Spark** e confirme camadas **raw/trusted/refined** no Delta Lake.
8. **Valide amostras de fraude** (geohash fora de SP/MG/RJ e troca de device).
9. **(Opcional)** Orquestre tudo no **Airflow** (pipelines agendados).

> **Pro tip:** ao final de cada etapa, anote 3 sinais de “OK” (ex.: tabela com linhas, arquivo no MinIO, mensagem no Kafka). Isso evita “perder-se” no meio do lab.

---

## 🆘 Erros comuns (e como resolver rápido)

* **Porta 9000 ocupada**: feche outros serviços S3 locais (ex.: outro MinIO) e reinicie.
* **Permissões do Docker** (Linux): adicione seu usuário ao grupo `docker` ou use `sudo`.
* **Containers reiniciando**: rode `docker compose logs -f <serviço>` e verifique variáveis obrigatórias.
* **AWS CLI não lista buckets**: confirme `--endpoint-url` e `--profile minio`.
* **Debezium não captura eventos**: garanta que o **wal_level** do Postgres esteja habilitado (conf. em `debezium-init/01_enable_replication.sql`).
* **DBT não encontra perfil**: verifique `dbt_project/profiles.yml` e caminho do profile local.

---
--

## 📚 Próximos passos (para quem quer ir além)

* Criar uma **tabela de features** (Delta) para o modelo antifraude.
* Orquestrar ingestão + DBT + Spark no **Airflow** com dependências explícitas.
* Adicionar **alertas** (fraude alta por período/UF) via jobs do Spark ou DAGs.
* Expor **dashboards** (BI) usando o DW dimensional.

---

## 👉 Continue no `quickstart/README.md`

Lá você encontra o **roteiro guiado** para executar os scripts, validar cada etapa e conferir exemplos práticos de consulta/inspeção de dados.
