# 🔎 Guia de Validação por Evidências

> Regra de ouro: **cada etapa deve deixar um rastro verificável**. Aqui vão evidências simples e objetivas para “dar check”.

## 1) Serviços no ar

* **Comando:** `docker compose ps`
* **Evidência:** todos os serviços relevantes como `Up (healthy)` ou `Up`.
* **Dica:** se algo reinicia, rode `docker compose logs -f <serviço>`.

## 2) MinIO acessível

* **URL:** `http://localhost:9000`
* **Login:** `sudoers123 / sudoers1234`
* **Evidência:** UI abre, buckets visíveis.

## 3) Buckets criados

* **Comandos (no container MinIO):**
  `mc mb local/raw`, `mc mb local/trusted`, `mc mb local/refined`
* **Evidência:** `mc ls local/` lista os três buckets.

## 4) AWS CLI (opcional)

* **Comando:**
  `aws s3 ls --endpoint-url http://localhost:9000 --profile minio`
* **Evidência:** aparece `raw`, `trusted`, `refined`.
* **Dica:** se não listar, revise `--endpoint-url` e o **profile**.

## 5) Dados históricos carregados

* **Evidência A:** arquivos novos em `raw/` (UI MinIO ou `aws s3 ls s3://raw ...`).
* **Evidência B:** tabelas/partições esperadas com crescimento após rodar `liga_sudoers_historico.py`.
* **Dica:** anote data/hora do run e compare timestamps dos objetos gerados.

## 6) CDC funcionando

* **Evidência A:** Debezium logs sem erro (ex.: conector Postgres registrado).
* **Evidência B:** Mensagens chegando no Kafka (tópicos criados/atualizados).
* **Dica:** mudanças no Postgres transacional devem refletir em eventos no Kafka.

## 7) Streaming ativo

* **Evidência:** ao rodar `liga_sudoers_streaming.py`, novos objetos/linhas surgem (veja `raw` e depois `trusted/refined` quando o pipeline roda).

## 8) DBT aplicou modelos

* **Evidência A:** `dbt.log` sem erros (`dbt_project/logs/dbt.log`).
* **Evidência B:** objetos/tabelas materializadas conforme `models/`.
* **Dica:** conferência cruzada: o que DBT promete em `models/` deve existir no destino.

## 9) Spark leu e escreveu

* **Evidência:** contagem de linhas esperada e schema correto nos datasets de saída (refined/Delta).
* **Dica:** valide uma **amostra** e um **count**; não confie só no “job succeeded”.

## 10) Regras de fraude respeitadas

* **Geohash/UF:** registros fora de **SP/MG/RJ** marcados como fraude.
* **Device drift:** mudança de device entre compras marca fraude.
* **Proporção:** ~1% (histórico) e ~5% (streaming). Pequenas variações são aceitáveis, mas fuja de 0% ou 30%.
