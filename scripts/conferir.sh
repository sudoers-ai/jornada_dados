#!/usr/bin/env bash
# ==========================================================================
# Confere se uma etapa da trilha foi feita, olhando o ESTADO do ambiente (e
# nao o que voce digitou): objetos no MinIO, tabelas no catalogo do Spark,
# conectores no Kafka Connect, linhas no PostgreSQL. Nao altera nada.
#
#   scripts/conferir.sh 0   ambiente          (README.md)
#   scripts/conferir.sh 1   modo old school   (quickstart/README.md)
#   scripts/conferir.sh 2   data lake e Delta (delta_lake/README.md)
#   scripts/conferir.sh 3   CDC e streaming   (debezium/README.md)
#   scripts/conferir.sh 4   dbt               (dbt_project/README.md)
#   scripts/conferir.sh 5   Airflow           (airflow_dags/README.md)
# ==========================================================================
set -uo pipefail
cd "$(dirname "$0")/.." && . scripts/comum.sh

e="${1:-}"
falhas=0
avisos=0
passou()   { ok "$*"; }
falhou()   { erro "$*"; falhas=$((falhas + 1)); }
lembrete() { aviso "$*"; avisos=$((avisos + 1)); }
titulo()   { echo; echo -e "${N}Conferindo a etapa $e - $1${F}"; echo; }

# para a conferencia se um servico de que a etapa depende nao esta no ar
precisa() {
  local s fora=""
  for s in "$@"; do no_ar "$s" || fora="$fora $s"; done
  if [ -n "$fora" ]; then
    echo; erro "fora do ar:$fora. Rode: make subir   (e veja: make status)"; echo; exit 1
  fi
}

# --------------------------------------------------------- catalogo do Spark
# As tabelas que voce cria no spark-sql ficam num catalogo (metastore) dentro
# do container spark. Ele aceita UMA sessao por vez: com um spark-sql aberto
# em outro terminal, a conferencia nao consegue ler o catalogo.
#
# O catalogo mora no disco do container, e nao num volume: ele sobrevive a
# parar e ligar (make parar / make subir), mas e apagado quando o container
# e recriado (docker compose down). Os DADOS continuam no MinIO. Por isso um
# catalogo vazio vira lembrete, e nao erro.
CATALOGO=""          # "#bancos default raw @raw dim_pessoas dim_produtos @trusted ..."
CATALOGO_ESTADO=""   # ok | vazio | ocupado | erro
VAZIO_EXPLICADO=""
carrega_catalogo() {  # carrega_catalogo raw trusted ...
  [ -n "$CATALOGO_ESTADO" ] && return
  if dex spark pgrep -f SparkSQLCLIDriver >/dev/null; then
    CATALOGO_ESTADO=ocupado; return
  fi
  local s consulta="SELECT '#bancos'; SHOW DATABASES;"
  for s in "$@"; do consulta="$consulta SELECT '@$s'; SHOW TABLES IN $s;"; done
  CATALOGO=$(LIMITE=90 dex spark spark-sql --hiveconf hive.cli.errors.ignore=true -e "$consulta" | tr '\n' ' ')
  case "$CATALOGO" in *"#bancos"*@*) CATALOGO_ESTADO=ok ;; *) CATALOGO_ESTADO=erro; return ;; esac
  # so o schema "default": nenhuma tabela foi criada neste container
  [ "$(echo "$CATALOGO" | sed -n 's/.*#bancos \([^@]*\)@.*/\1/p' | tr -d ' ')" = "default" ] && CATALOGO_ESTADO=vazio
}

# tabelas "schema" "t1 t2 t3" "onde no roteiro"
tabelas() {
  local schema="$1" faltam="" t lista
  case "$CATALOGO_ESTADO" in
    ocupado) lembrete "catálogo do Spark: não conferi as tabelas de '$schema' (há um spark-sql aberto: saia dele com exit; e rode de novo)"; return ;;
    erro)    lembrete "catálogo do Spark: não consegui ler as tabelas de '$schema' (o spark está respondendo? make logs s=spark)"; return ;;
    vazio)
      if [ -z "$VAZIO_EXPLICADO" ]; then
        VAZIO_EXPLICADO=1
        lembrete "catálogo do Spark vazio: não há as tabelas de '$schema' ($3)"
        echo -e "       ${C}Ainda não fez esse passo? Faça. Já tinha feito? O catálogo é apagado quando o container${F}"
        echo -e "       ${C}spark é recriado (docker compose down). Os dados continuam no MinIO: recrie as tabelas.${F}"
      else
        lembrete "catálogo do Spark vazio: não há as tabelas de '$schema' ($3)"
      fi
      return ;;
  esac
  # o trecho do catalogo deste schema: do "@schema" ate o proximo "@"
  lista=" $(echo "$CATALOGO" | sed -n "s/.*@$schema \([^@]*\).*/\1/p") "
  for t in $2; do
    case "$lista" in *" $t "*) ;; *) faltam="$faltam $t" ;; esac
  done
  if [ -z "$faltam" ]; then passou "catálogo do Spark, schema $schema: $(echo "$2" | tr ' ' ',' | sed 's/,/, /g')"
  else falhou "catálogo do Spark, schema $schema: falta(m)$faltam ($3)"; fi
}

# objetos caminho "descricao" "onde no roteiro"
objetos() {
  if tem_objetos "$1"; then passou "$2: s3a://$1/"
  else falhou "$2: nada em s3a://$1/ ($3)"; fi
}

# delta "bucket" "t1 t2" "descricao" "onde no roteiro"
delta() {
  local faltam="" t
  for t in $2; do tabela_delta "$1/$t" || faltam="$faltam $t"; done
  if [ -z "$faltam" ]; then passou "$3: $(echo "$2" | tr ' ' ',' | sed 's/,/, /g') em s3a://$1/"
  else falhou "$3: falta(m)$faltam em s3a://$1/ ($4)"; fi
}

buckets() {  # buckets "b1 b2 b3" "onde no roteiro"
  local faltam="" b
  for b in $1; do bucket "$b" || faltam="$faltam $b"; done
  if [ -z "$faltam" ]; then passou "buckets no MinIO: $(echo "$1" | tr ' ' ',' | sed 's/,/, /g')"
  else falhou "buckets no MinIO: falta(m)$faltam ($2)"; fi
}

case "$e" in
# --------------------------------------------------------------------------
0)
  titulo "Ambiente (README.md)"
  fora=""
  for s in $SERVICOS; do no_ar "$s" || fora="$fora $s"; done
  if [ -z "$fora" ]; then passou "os 8 serviços estão no ar"
  else falhou "serviço(s) fora do ar:$fora (make subir; o motivo aparece em make logs s=NOME)"; fi

  n=$(oltp "SELECT count(*) FROM pedidos")
  if [ "${n:-0}" -gt 0 ] 2>/dev/null; then passou "PostgreSQL transacional (OLTP): $n pedidos carregados"
  else falhou "PostgreSQL transacional (OLTP) não respondeu ou está sem pedidos (make logs s=postgres_oltp)"; fi

  n=$(olap "SELECT count(*) FROM fato_pedidos")
  if [ "${n:-0}" -gt 0 ] 2>/dev/null; then passou "PostgreSQL analítico (DW): $n linhas na fato_pedidos"
  else falhou "PostgreSQL analítico (DW) não respondeu ou está vazio (make logs s=postgres_olap)"; fi

  if mc_ ls c/ >/dev/null; then passou "MinIO responde"
  else falhou "MinIO não respondeu (make logs s=minio)"; fi
  buckets "raw trusted refined" "README, Modo Terminal — MinIO: mc mb local/raw ..."

  if [ -n "$(dex debezium curl -s -m 8 http://localhost:8083/connectors)" ]; then passou "Kafka Connect (Debezium) responde"
  else lembrete "Kafka Connect (Debezium) ainda não responde: ele leva cerca de 1 minuto depois do make subir"; fi

  if [ "$(dex airflow curl -s -m 8 -o /dev/null -w '%{http_code}' http://localhost:8080/health)" = 200 ]; then passou "Airflow responde"
  else lembrete "Airflow ainda não responde: ele leva cerca de 1 minuto depois do make subir"; fi
  ;;

# --------------------------------------------------------------------------
1)
  titulo "Modo old school (quickstart/README.md)"
  precisa minio spark
  carrega_catalogo raw

  if tem_objetos raw/dim_pessoas; then
    n=$(mc_ cat c/raw/dim_pessoas/dim_pessoas.csv | wc -l | tr -d ' ')
    if [ "${n:-0}" -gt 1 ]; then passou "dim_pessoas.csv no armazenamento distribuído: s3a://raw/dim_pessoas/ ($n linhas)"
    else falhou "s3a://raw/dim_pessoas/dim_pessoas.csv está vazio ou com outro nome (seção HIVE: mc cp)"; fi
  else
    falhou "dim_pessoas.csv não está em s3a://raw/dim_pessoas/ (seção HIVE: mc cp /home/dim_pessoas.csv ...)"
  fi
  tabelas raw "dim_pessoas" "seção Spark-SQL: CREATE EXTERNAL TABLE"
  ;;

# --------------------------------------------------------------------------
2)
  titulo "Data lake e Delta Lake (delta_lake/README.md)"
  precisa minio spark postgres_olap
  carrega_catalogo olap raw trusted refined

  tabelas olap "dim_pessoas dim_produtos fato_pedidos" "federação com o PostgreSQL: CREATE TABLE ... USING jdbc"

  objetos raw/dim_produtos "zona raw, dim_produtos" "INSERT OVERWRITE TABLE dim_produtos"
  n=$(mc_ ls c/raw/fato_pedidos/ | grep -c 'dt_venda=')
  if [ "${n:-0}" -gt 0 ]; then passou "zona raw, fato_pedidos particionada: $n partições dt_venda= em s3a://raw/fato_pedidos/"
  else falhou "zona raw, fato_pedidos: nenhuma partição dt_venda= em s3a://raw/fato_pedidos/ (INSERT OVERWRITE ... PARTITION (dt_venda))"; fi

  faltam=""
  for t in dim_pessoas dim_produtos fato_pedidos; do tem_objetos "trusted/$t" || faltam="$faltam $t"; done
  if [ -z "$faltam" ]; then passou "zona trusted (parquet): dim_pessoas, dim_produtos, fato_pedidos"
  else falhou "zona trusted: falta(m)$faltam em s3a://trusted/ (Raw → Trusted)"; fi
  objetos refined/itens_by_person "zona refined, itens_by_person" "Trusted → Refined"

  tabelas trusted "ttl_dim_pessoas dim_pessoas_v2" "DELETE, UPDATE e time travel feitos à mão no parquet"

  delta trusted "dim_pessoas_delta dim_produtos_delta fato_pedidos_delta" "tabelas Delta" "seção Delta Lake"
  if tabela_delta trusted/dim_pessoas_delta; then
    ops=" $(operacoes_delta trusted/dim_pessoas_delta | tr '\n' ' ')"
    faltam=""
    for o in UPDATE DELETE RESTORE; do case "$ops" in *" $o "*) ;; *) faltam="$faltam $o" ;; esac; done
    if [ -z "$faltam" ]; then passou "DML e time travel na dim_pessoas_delta: UPDATE, DELETE e RESTORE no log de transações"
    else falhou "dim_pessoas_delta: falta(m) no log de transações:$faltam (seções Fazendo DML e TimeTravel)"; fi
  fi
  ;;

# --------------------------------------------------------------------------
3)
  titulo "CDC e streaming (debezium/README.md)"
  precisa postgres_oltp kafka debezium minio spark
  carrega_catalogo raw
  TOPICO=liga_sudoers.public.pessoas

  if [ "$(oltp "SHOW wal_level")" = logical ]; then passou "PostgreSQL com wal_level = logical"
  else falhou "wal_level não é logical: o Debezium não consegue ler o log de transações (docker-compose.yml)"; fi

  if oltp_v "SELECT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'pessoas_pub' AND tablename = 'pessoas')"; then
    passou "publicação pessoas_pub com a tabela pessoas"
  else falhou "falta a publicação pessoas_pub (Configurando o PostgreSQL: CREATE PUBLICATION)"; fi

  if oltp_v "SELECT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'debezium' AND rolreplication)"; then
    passou "usuário debezium com permissão de replicação"
  else falhou "falta o usuário debezium WITH REPLICATION (Configurando o PostgreSQL: CREATE USER)"; fi

  c=$(conector postgres-connector-pessoas)
  case "$c" in
    RUNNING) passou "conector postgres-connector-pessoas (PostgreSQL → Kafka): RUNNING" ;;
    AUSENTE) falhou "conector postgres-connector-pessoas não cadastrado (curl ... --data @debezium-postgres.json)" ;;
    FAILED|PAUSED) falhou "conector postgres-connector-pessoas: $c (veja o motivo: curl -s http://debezium:8083/connectors/postgres-connector-pessoas/status)" ;;
    *)       lembrete "conector postgres-connector-pessoas ainda iniciando ($c): espere alguns segundos e confira de novo" ;;
  esac

  if oltp_v "SELECT EXISTS (SELECT 1 FROM pg_replication_slots WHERE slot_name = 'debezium_slot' AND active)"; then
    passou "slot de replicação debezium_slot ativo"
  else falhou "slot de replicação debezium_slot ausente ou inativo (o conector do PostgreSQL está rodando?)"; fi

  if topico "$TOPICO"; then
    m=$(mensagens "$TOPICO"); p=$(oltp "SELECT count(*) FROM pessoas")
    passou "tópico $TOPICO no Kafka: $m mensagens"
  else
    m=0; p=0
    falhou "tópico $TOPICO não existe no Kafka (ele nasce quando o conector do PostgreSQL roda)"
  fi

  c=$(conector minio-sink-connector)
  case "$c" in
    RUNNING) passou "conector minio-sink-connector (Kafka → MinIO): RUNNING" ;;
    AUSENTE) falhou "conector minio-sink-connector não cadastrado (curl ... --data @minio-sink.json)" ;;
    FAILED|PAUSED) falhou "conector minio-sink-connector: $c (veja o motivo: curl -s http://debezium:8083/connectors/minio-sink-connector/status)" ;;
    *)       lembrete "conector minio-sink-connector ainda iniciando ($c): espere alguns segundos e confira de novo" ;;
  esac

  if tem_objetos "raw/topics/$TOPICO"; then passou "eventos de CDC no data lake: s3a://raw/topics/$TOPICO/"
  else falhou "nenhum evento em s3a://raw/topics/$TOPICO/ (o minio-sink-connector grava a cada 10 mensagens)"; fi

  # cada linha viva gerou 1 mensagem; update e delete geram mensagens a mais
  if [ "${m:-0}" -gt "${p:-0}" ] && [ "${p:-0}" -gt 0 ]; then passou "mutações capturadas: há updates ou deletes além da carga inicial"
  else lembrete "só a carga inicial foi capturada: rode python airflow_dags/liga_sudoers_cdc_demo.py para ver update e delete"; fi

  tabelas raw "pessoas_cdc" "Lendo os dados gerados pelo CDC: CREATE TABLE raw.pessoas_cdc"
  ;;

# --------------------------------------------------------------------------
4)
  titulo "dbt e arquitetura medalhão (dbt_project/README.md)"
  precisa minio spark postgres_oltp
  carrega_catalogo oltp bronze silver gold

  buckets "bronze silver gold" "Preparando tabelas para DBT: mc mb local/bronze ..."
  tabelas oltp "pessoas categorias produtos pedidos itens_pedidos auditoria_pedidos" "federação do OLTP: CREATE TABLE ... USING jdbc"

  antes=$falhas
  delta bronze "pessoas categorias produtos pedidos itens_pedidos auditoria_pedidos" "camada bronze (Delta)" "dbt run --select models/bronze"
  delta silver "dim_pessoas dim_produtos fato_pedidos" "camada silver (Delta)" "dbt run --select models/silver"
  delta gold "itens_by_person" "camada gold (Delta)" "dbt run --select models/gold"

  # o dbt e instalado com pip DENTRO do container: some se o container for recriado
  if LIMITE=30 dex spark bash -c 'export PATH=~/.local/bin:$PATH; command -v dbt' >/dev/null; then passou "dbt instalado no container spark"
  elif [ "$falhas" = "$antes" ]; then lembrete "as três camadas existem, mas o dbt não está mais instalado no container spark (ele some quando o container é recriado): reinstale para rodar de novo, inclusive pela DAG do Airflow (Instalando o DBT)"
  else falhou "dbt não está instalado no container spark (Instalando o DBT: pip install dbt-spark dbt-core)"; fi
  ;;

# --------------------------------------------------------------------------
5)
  titulo "Orquestração com Airflow (airflow_dags/README.md)"
  precisa airflow postgres_oltp
  af() { oltp "$1" airflow; }

  if [ "$(af "SELECT count(*) FROM ab_user WHERE username = 'liga_sudoers'")" = 1 ]; then passou "usuário liga_sudoers criado no Airflow"
  else falhou "falta o usuário liga_sudoers (Configurar o usuário do Airflow: airflow users create)"; fi

  # o scheduler grava um "estou vivo" no banco do Airflow a cada poucos segundos
  if [ "$(af "SELECT count(*) > 0 FROM job WHERE job_type = 'SchedulerJob' AND state = 'running'
              AND latest_heartbeat > now() - interval '30 seconds'")" = t ]; then passou "scheduler do Airflow rodando"
  else falhou "o scheduler não está rodando: sem ele nenhuma DAG executa (airflow scheduler, num terminal que fica aberto)"; fi

  n=$(af "SELECT count(*) FROM import_error")
  if [ "${n:-0}" = 0 ]; then passou "DAGs carregadas sem erro de importação"
  else falhou "$n DAG(s) com erro de importação (airflow dags list-import-errors)"; fi

  pausada=$(af "SELECT is_paused FROM dag WHERE dag_id = 'dbt_run_dag'")
  case "$pausada" in
    f) passou "DAG dbt_run_dag ativa (fora da pausa)" ;;
    t) falhou "DAG dbt_run_dag ainda está em pausa (airflow dags unpause dbt_run_dag)" ;;
    *) falhou "DAG dbt_run_dag ainda não foi registrada (o scheduler registra as DAGs: airflow scheduler)" ;;
  esac

  ultima=$(af "SELECT state FROM dag_run WHERE dag_id = 'dbt_run_dag' ORDER BY execution_date DESC LIMIT 1")
  case "$ultima" in
    success)        passou "última execução da dbt_run_dag: success" ;;
    running|queued) lembrete "dbt_run_dag em execução ($ultima): espere terminar e confira de novo" ;;
    failed)         falhou "última execução da dbt_run_dag: failed (o log da tarefa mostra o motivo: localhost:8080)" ;;
    *)              falhou "a dbt_run_dag ainda não foi executada (rode a DAG pela tela, em localhost:8080)" ;;
  esac
  ;;

*)
  echo "uso: make conferir e=0   (a etapa: 0 ambiente, 1 quickstart, 2 delta_lake, 3 debezium, 4 dbt, 5 airflow)"; exit 1 ;;
esac

echo
if [ "$falhas" -gt 0 ]; then
  echo -e "${R}${falhas} item(ns) a corrigir.${F} O trecho do roteiro entre parênteses mostra como."
  echo; exit 1
fi
if [ "$avisos" -gt 0 ]; then
  echo -e "${V}✅ Etapa $e conferida.${F} ${A}Faltam ${avisos} lembrete(s) acima.${F}"
else
  echo -e "${V}✅ Etapa $e conferida.${F}"
fi
echo
