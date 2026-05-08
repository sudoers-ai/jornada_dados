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

## 📚 Documentação e Material de Apoio

Para garantir que você não se perca durante o desafio, preparamos materiais de apoio detalhados:

* [✅ Checklist Imprimível (Aluno)](./docs/checklist.md) — Passo a passo para você acompanhar seu progresso.
* [🔎 Guia de Validação por Evidências](./docs/validacao_evidencia.md) — Dicas de como testar e comprovar que cada ferramenta subiu corretamente.
* [❓ FAQ de Aula (Erros Comuns) ](./docs/faq.md) — Respostas e soluções rápidas para portas ocupadas, permissões, etc.
* [👩‍💻 Perfis e Responsabilidades](./docs/perfis.md) — Entenda o papel do Engenheiro, Arquiteto, Cientista de Dados, etc.
* [🧪 Desafios por Nível](./desafios/desafios.md) — Tarefas práticas divididas para níveis Júnior, Pleno e Sênior.

> **Dica**: ao longo do desafio, use o Checklist e tente enxergar suas tarefas sob cada um dos perfis profissionais. Isso acelera sua visão de arquitetura.

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

Para não se perder na jornada, recomendamos fortemente que você acompanhe o seu progresso através do nosso **[Checklist do Aluno](./docs/checklist.md)** e valide cada etapa com o **[Guia de Validação por Evidências](./docs/validacao_evidencia.md)**!

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

Encontrou algum erro ao subir os containers, conflito de portas no MinIO, problemas de permissão no Docker ou o Spark/DBT não estão rodando como deveriam? 

Preparamos um documento completo com as soluções rápidas para os problemas mais relatados:

👉 **[Acesse o FAQ de Aula (Erros Comuns & Soluções)](./docs/faq.md)**

---

## 📚 Próximos passos (para quem quer ir além)

Quer testar seus conhecimentos e montar um portfólio bacana? Preparamos uma trilha de desafios separados por nível de senioridade!

👉 **[Acesse a Área de Desafios da Jornada](./desafios/desafios.md)**

Lá você encontrará propostas práticas para os níveis **Júnior**, **Pleno** e **Sênior**, envolvendo desde a execução ponta a ponta até otimizações de performance, qualidade de dados e observabilidade.

---

## 👉 Continue no `quickstart/README.md`

Lá você encontra o **roteiro guiado** para executar os scripts, validar cada etapa e conferir exemplos práticos de consulta/inspeção de dados.
