# ❓ FAQ de Aula (Erros Comuns & Soluções Rápidas)

**1) “Não consigo acessar `http://localhost:9000`.”**

* Verifique se a stack está de pé: `docker compose ps`.
* Confirme se a porta 9000 não está em uso por outro serviço (pare o serviço conflitante).
* Rode `docker compose logs -f minio` para ver erros.

**2) “Criei os buckets, mas a AWS CLI não lista nada.”**

* Confira o **endpoint**: `--endpoint-url http://localhost:9000`.
* Use o **profile** correto: `--profile minio`.
* Refaça o `aws configure --profile minio` (Access/Secret ok?).

**3) “Debezium não captura alterações.”**

* Certifique-se que o Postgres está com `wal_level=logical` e demais configs ativadas (vide `debezium-init/01_enable_replication.sql`).
* Veja se o **conector** foi registrado e está `RUNNING` nos logs.
* Gere uma alteração **real** no banco transacional para testar.

**4) “Kafka sem eventos.”**

* Cheque se os tópicos foram criados.
* Garanta que o Debezium está apontando para o Kafka correto.
* Revise variáveis de ambiente nos containers relacionados.

**5) “DBT falhando por perfil.”**

* Verifique `dbt_project/profiles.yml` e o path do profile local.
* Confirme permissões/credenciais do destino.
* Veja `dbt_project/logs/dbt.log` para a causa exata.

**6) “Spark executa mas não vejo dados no refined.”**

* Valide primeiro **raw** e **trusted** (pipeline pode ter parado antes).
* Cheque contagens de linha e schemas intermediários.
* Logs do Spark indicam se houve erro silencioso no write.

**7) “As fraudes não aparecem.”**

* Gere amostra suficiente (dados históricos + streaming).
* Teste manualmente um registro **fora de SP/MG/RJ**.
* Force mudança de **device** para um mesmo cliente.
* Se a taxa cair para ~0%, revise regras de marcação no fluxo.

**8) “Containers reiniciam em loop.”**

* `docker compose logs -f <serviço>` e procure por: variável ausente, porta em uso, credencial inválida.
* Verifique dependências (ex.: serviço A sobe antes do B?).
* Pare tudo e suba novamente: `docker compose stop` → `docker compose up`.

**9) “Permissão negada no Docker (Linux).”**

* Adicione seu usuário ao grupo `docker`:
  `sudo usermod -aG docker $USER` (efetive logoff/login).
* Ou rode com `sudo`.

**10) “Qual a ordem recomendada para não quebrar?”**

1. Subir stack → 2) MinIO/buckets → 3) Histórico → 4) CDC/Kafka →
2. Streaming → 6) DBT → 7) Spark → 8) Validação de fraude → 9) Orquestração (Airflow).