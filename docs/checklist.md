# ✅ Checklist Imprimível (Aluno)

> Use este checklist para não se perder entre as etapas. Marque cada item **somente após validar a evidência** correspondente.

### 1) Preparação do ambiente

* [ ] Python 3.x instalado
* [ ] Docker + Docker Compose instalados
* [ ] Bibliotecas `psycopg2` e `Faker` instaladas
* [ ] Porta 9000 livre (MinIO)

### 2) Subir a stack

* [ ] `docker compose up --build` finalizado sem erros
* [ ] `docker compose ps` mostra serviços “running/healthy”
* [ ] Consigo abrir `http://localhost:9000` (UI MinIO)

### 3) MinIO básico

* [ ] Entrei no container: `docker exec -it minio sh`
* [ ] Configurei alias: `mc alias set local http://minio:9000 sudoers123 sudoers1234`
* [ ] Criei buckets: `local/raw`, `local/trusted`, `local/refined`
* [ ] Deixei públicos: `mc anonymous set public ...`

### 4) Validação via AWS CLI (opcional)

* [ ] Perfil criado `aws configure --profile minio`
* [ ] `aws s3 ls --endpoint-url http://localhost:9000 --profile minio` lista buckets
* [ ] `aws s3 ls s3://raw --endpoint-url ...` lista objetos (se houver)

### 5) Dados históricos (simulação)

* [ ] Rodei `liga_sudoers_historico.py` (popular dados base)
* [ ] Verifiquei que os arquivos/tabelas foram criados (evidência no MinIO ou banco)

### 6) CDC + Streaming

* [ ] Debezium ativo (sem erros nos logs)
* [ ] Kafka recebendo eventos (verificação por logs ou consumidor simples)
* [ ] Rodei `liga_sudoers_streaming.py` e validei novos registros chegando

### 7) Transformações/Analytics

* [ ] DBT executa com sucesso (modelos materializados)
* [ ] Camadas `raw → trusted → refined` preenchidas no MinIO
* [ ] Spark lê dados e confirma schema/contagem

### 8) Antifraude: sanity check

* [ ] Geohash fora de **SP/MG/RJ** marcado como fraude
* [ ] Mudança de **device** marcada como fraude
* [ ] Amostragem com % próxima a **1% histórico** e **5% streaming**

### 9) (Opcional) Airflow

* [ ] DAGs aparecem na UI
* [ ] Execução orquestrada sem falhas
