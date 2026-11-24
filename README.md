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

## 📺 Recursos complementares

O curso [do Transacional ao Big Data](https://www.youtube.com/watch?v=ynrL9EMXX5A&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT) acompanha a Jornada inteira em vídeo. O Mapa 02 e o fechamento usam este repositório; a introdução e o Mapa 01 (transacional, dimensional, Apache Hop e dashboards) usam o [`liga_sudoers`](https://github.com/sudoers-ai/liga_sudoers).

**Mapa Engenharia de Dados 02 — Do Transacional ao Big Data (este repositório)**
- [Aula 01 - Olhando para o presente](https://www.youtube.com/watch?v=eMlWeO_bOyI&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=22)  
- [Aula 02 - Git New Game](https://www.youtube.com/watch?v=FGNX5V7Ug-8&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=23)  
- [Aula 03 - Iniciando o New Game](https://www.youtube.com/watch?v=3qxYuwKE2FQ&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=24)  
- [Aula 04 - SQL](https://www.youtube.com/watch?v=zKQw_96fhd8&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=25)  
- [Aula 05 - Ingestão e Processamento](https://www.youtube.com/watch?v=Zf_tqpZoC0w&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=26)  
- [Aula 06 - Zona Raw](https://www.youtube.com/watch?v=vztJ0ni4oY8&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=27)  
- [Aula 07 - Zonas](https://www.youtube.com/watch?v=MPjxIrXJB6E&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=28)  
- [Aula 08 - Zonas e Camada Medalhão](https://www.youtube.com/watch?v=U2IR65IFoRo&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=29)  
- [Aula 09 - Simulando Delta](https://www.youtube.com/watch?v=ErSE1YH3oOk&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=30)  
- [Aula 10 - Delta Lake](https://www.youtube.com/watch?v=BQwbPlHTvFk&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=31)  
- [Aula 11 - Delta e Parquet](https://www.youtube.com/watch?v=oZlhQDpP2o0&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=32)  
- [Aula 12 - Formatos de Arquivos (Hudi, Delta, Iceberg)](https://www.youtube.com/watch?v=uqm6x2mjJuA&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=33)  
- [Aula 13 - Fundamentos de Dados](https://www.youtube.com/watch?v=EK2eNzZT6lk&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=34)  
- [Aula 14 - Data Lake vs DW vs Lakehouse](https://www.youtube.com/watch?v=fypYvwFgwNQ&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=35)  
- [Aula 15 - Ferramentas para Realtime](https://www.youtube.com/watch?v=PHh2s2NsfoQ&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=36)  
- [Aula 16 - A importância da Durabilidade](https://www.youtube.com/watch?v=SbPvboEf5lE&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=37)  
- [Aula 17 - Durabilidade: mão na massa](https://www.youtube.com/watch?v=RJDlf1eJiKk&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=38)  
- [Aula 18 - Streaming](https://www.youtube.com/watch?v=gnHJrsGMIQc&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=39)  
- [Aula 19 - Entendendo o DBT](https://www.youtube.com/watch?v=8FlTcSvS_gU&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=40)  
- [Aula 20 - DBT na prática](https://www.youtube.com/watch?v=EOar4HHU7wM&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=41)  
- [Aula 21 - Introdução ao Airflow](https://www.youtube.com/watch?v=teOaGidr4a8&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=42)  
- [Aula 22 - Airflow na prática](https://www.youtube.com/watch?v=PjfHY-EWuZs&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=43)  
- [Aula 23 - DataOps](https://www.youtube.com/watch?v=yTZyATYkNj8&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=44)  

**Qualidade, Governança e Tendências**
- [Aula 01 - Qualidade em Dados](https://www.youtube.com/watch?v=FdxxQfWHMeQ&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=45)  
- [Aula 02 - Governança de Dados](https://www.youtube.com/watch?v=SaSXiymcBUE&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=46)  
- [Aula 03 - Ferramentas e metodologia para governança](https://www.youtube.com/watch?v=p-1COTAHoS4&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=47)  
- [Aula 04 - Data Mesh](https://www.youtube.com/watch?v=NbyxUyfEU-w&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=48)  
- [Aula 05 - Tendências](https://www.youtube.com/watch?v=12IF4meoeu8&list=PLD3-a_5KsN3kBwoeBT78q1ZyARwtwhjwT&index=49)  

Deixe seu like e comentário nos vídeos do YouTube, isso ajuda e incentiva nosso trabalho.

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
├── Makefile                  # atalhos: make status, make conferir e=N
├── postgresql-init
│   └── 02_create_airflow_db.sql
├── quickstart
│   ├── organizations.csv
│   └── people.zip
├── scripts                   # status.sh e conferir.sh (usados pelo Makefile)
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
* [🗄️ Parte 2 — o lado NoSQL](https://github.com/sudoers-ai/jornada_dados_nosql) — Cinco bancos não relacionais que servem de **origem** para esta arquitetura.

> **Dica**: ao longo do desafio, use o Checklist e tente enxergar suas tarefas sob cada um dos perfis profissionais. Isso acelera sua visão de arquitetura.

---

## ✅ Pré-requisitos (checklist rápido)

* [ ] **Python 3.x** instalado
* [ ] **Docker** e **Docker Compose** instalados
* [ ] **make** instalado (para os atalhos `make status` e `make conferir`)
* [ ] Bibliotecas Python: `psycopg2`, `Faker`
* [ ] Portas livres: **9000** e **9001** (MinIO), **8080** (Airflow), **5432** e **5433** (PostgreSQL), **8083** (Debezium), **9092** (Kafka), **2181** (Zookeeper), **7077**, **8081** e **8085** (Spark)

**Passo a passo de instalação, do zero:**

* 🪟 **Windows:** [docs/windows.md](./docs/windows.md) (WSL2 com Ubuntu, Docker, `make`, Python e o repositório)
* 🐧 **Linux (Ubuntu):** [docs/linux.md](./docs/linux.md) (Docker, `make`, Python e o repositório)

> No Windows, tudo roda no **terminal do Ubuntu (WSL2)**, e não no PowerShell; no Mac, certifique-se de dar permissão de recursos (CPU/RAM) no Docker Desktop.

---

## ⚙️ Instalação do Docker Compose

```bash
sudo apt update
sudo apt install docker-compose-plugin awscli make
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

### 🧭 Onde eu parei? Fiz certo?

Dois atalhos respondem a essas perguntas olhando o **estado** do ambiente
(objetos no MinIO, tabelas do Spark, conectores, DAGs), e não o que você
digitou. Eles só leem: não alteram nada.

```bash
make status          # os 8 serviços e o que já foi feito em cada etapa
make conferir e=2    # o detalhe de uma etapa, item por item
```

| Etapa | Roteiro | O que o `make conferir` olha |
|---|---|---|
| `e=0` | este README | serviços no ar, dados nos dois PostgreSQL, buckets `raw`, `trusted`, `refined` |
| `e=1` | [quickstart](./quickstart/README.md) | `dim_pessoas.csv` no MinIO e a tabela `raw.dim_pessoas` |
| `e=2` | [delta_lake](./delta_lake/README.md) | zonas raw, trusted e refined, tabelas Delta, DML e time travel |
| `e=3` | [debezium](./debezium/README.md) | publicação, conectores `RUNNING`, tópico no Kafka, eventos no data lake |
| `e=4` | [dbt_project](./dbt_project/README.md) | camadas bronze, silver e gold materializadas em Delta |
| `e=5` | [airflow_dags](./airflow_dags/README.md) | usuário, scheduler, DAG ativa e executada com sucesso |

Cada ❌ diz, entre parênteses, qual trecho do roteiro resolve. `make ajuda`
lista os outros atalhos (`make subir`, `make parar`, `make logs s=debezium`).

> As tabelas do `spark-sql` ficam num catálogo que aceita **uma sessão por
> vez**. Com um `spark-sql` aberto em outro terminal, o `make conferir` avisa
> (⚠️) que não conseguiu ler as tabelas: saia com `exit;` e rode de novo.

### 💾 O que sobrevive quando eu desligo?

| O que você fez | `make parar` (ou `docker compose stop`) | `docker compose down` (recria os containers) |
|---|---|---|
| Arquivos e tabelas Delta no MinIO, dados dos PostgreSQL, usuário e histórico do Airflow | ficam | ficam (estão em volumes) |
| Catálogo do `spark-sql` (os `CREATE SCHEMA` e `CREATE TABLE`) | fica | **é apagado** |
| `dbt` instalado no container spark (`pip install`) | fica | **é apagado** |
| Tópicos do Kafka e os dois conectores (Debezium e MinIO sink) | ficam | **são apagados** |
| `airflow scheduler` (o processo que você iniciou no terminal) | **para** | **para** |

Por isso, para encerrar uma sessão de estudo, use **`make parar`**, e não o
`docker compose down`. Na volta (`make subir`), só o `airflow scheduler`
precisa ser iniciado de novo.

Recriou os containers? Os **dados** continuam no MinIO e nos PostgreSQL. O
que volta a ser feito:

* **Spark:** rode de novo os `CREATE SCHEMA` e `CREATE TABLE` do roteiro. As tabelas com `LOCATION 's3a://...'` voltam a enxergar os arquivos que já estão lá.
* **dbt:** reinstale no container spark (seção *Instalando o DBT*).
* **CDC:** cadastre de novo os dois conectores (os `curl ... --data @...json` do roteiro do Debezium).

Nesse caso o `make conferir` mostra as tabelas do catálogo e o `dbt` como
lembrete (⚠️), e os conectores como ❌ até serem recadastrados.


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

Para não se perder na jornada, recomendamos fortemente que você acompanhe o seu progresso através do nosso **[Checklist do Aluno](./docs/checklist.md)** e valide cada etapa com o **[Guia de Validação por Evidências](./docs/validacao_evidencia.md)**! No terminal, `make status` mostra onde você parou e `make conferir e=N` confere cada etapa.

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

## 🗄️ Parte 2 — o lado NoSQL

Este repositório te ensina a mover o dado. O próximo te ensina a **decidir onde ele deve morar**.

👉 **[sudoers-ai/jornada_dados_nosql](https://github.com/sudoers-ai/jornada_dados_nosql)**

Lá você sobe cinco bancos não relacionais, cada um resolvendo um problema que o PostgreSQL desta arquitetura resolveria mal:

| Paradigma | Banco | O problema que ele resolve |
|---|---|---|
| 📄 Documento | MongoDB | produto de categoria diferente tem atributo diferente (livro tem ISBN, eletrônico tem voltagem) |
| 🔑 Chave-valor | Redis | decidir em menos de 1 ms, durante o checkout, se o cliente trocou de dispositivo |
| 🕸️ Grafo | Neo4j | **anel de fraude**: cinco contas, cinco CPFs, o mesmo aparelho físico |
| 🏛️ Wide-column | Cassandra | clickstream — escrita massiva, modelagem por consulta |
| 📈 Colunar | ClickHouse | agregação sobre tudo, em milissegundos, para o dashboard |

### Como os dois repositórios se conectam

O repositório NoSQL é **origem** deste aqui. Ele usa o mesmo universo Liga Sudoers, gerado com a **mesma semente** — então `pessoas.id = 1` é a **mesma pessoa** nos dois lados. Isso é o que permite seguir um cliente atravessando a arquitetura inteira.

São três pontes:

1. **Carga no Postgres OLTP** — popula as tabelas deste repositório com o universo canônico, e a partir daí o pipeline daqui (Debezium → Kafka → Spark → Delta → DW) roda como sempre.
2. **Export batch para o MinIO** — grava os cinco bancos na zona `raw`, prontos para o Spark promover a `trusted`/`refined`.
3. **CDC do MongoDB** — usa o **mesmo Debezium e o mesmo Kafka** desta stack, agora com o `MongoDbConnector`. Mesma ideia do CDC do Postgres que você já viu, origem diferente.

E o caminho de volta: o Neo4j exporta um **score de risco por pessoa**, calculado a partir da rede de contas. É uma feature antifraude que nenhuma regra de linha produz — e que entra na camada `gold` para o treino do modelo.

> **Nota:** o gerador de dados canônico (`gerador/liga_sudoers_gen.py`) vive naquele repositório e é determinístico. Ele também cobre o papel do `liga_sudoers_historico.py` citado neste README.

### Pré-requisito

Conclua pelo menos o **desafio Júnior** deste repositório antes de ir para lá. A trilha NoSQL assume que você já viu o pipeline relacional funcionando ponta a ponta.

---

## 👉 Continue no [quickstart/README.md](./quickstart/README.md)

Lá você encontra o **roteiro guiado** para executar os scripts, validar cada etapa e conferir exemplos práticos de consulta/inspeção de dados.
