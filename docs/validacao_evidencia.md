# 🔎 Guia de Validação por Evidências

> Regra de ouro: **cada etapa deve deixar um rastro verificável**. Aqui vão evidências simples e objetivas para “dar check”.

## Conferência automática

Boa parte das evidências abaixo é conferida por dois atalhos, que só leem o
ambiente (nada é alterado):

```bash
make status          # os serviços e um resumo de cada etapa
make conferir e=3    # uma etapa, item por item (0 a 5)
```

| Evidência deste guia | Conferida em |
|---|---|
| 1, 2 e 3 (serviços, MinIO, buckets) | `make conferir e=0` |
| 6 (CDC funcionando) | `make conferir e=3` |
| 8 (DBT aplicou modelos) | `make conferir e=4` |
| 9 (Spark leu e escreveu) | `make conferir e=1` e `e=2` |
| orquestração no Airflow | `make conferir e=5` |

O `make conferir` olha se o rastro **existe** (o arquivo, a tabela, o
conector rodando). As evidências 5, 7 e 10 (dados históricos, streaming e
regras de fraude) dependem do que você gerou e analisou: essas continuam
sendo conferidas por você, com os passos abaixo.

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
