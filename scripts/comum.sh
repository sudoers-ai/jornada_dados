#!/usr/bin/env bash
# Funcoes e cores usadas pelo status.sh e pelo conferir.sh.
#
# Tudo aqui so LE o ambiente. Os comandos rodam DENTRO dos containers
# (docker exec), entao nao dependem de portas livres nem de ferramentas
# instaladas na sua maquina.
V="\033[92m"; A="\033[93m"; R="\033[91m"; C="\033[90m"; N="\033[1m"; F="\033[0m"

# os 8 servicos do docker-compose.yml, na ordem em que a trilha os usa
SERVICOS="postgres_oltp postgres_olap minio spark zookeeper kafka debezium airflow"

ok()    { echo -e "  ${V}✅${F} $*"; }
aviso() { echo -e "  ${A}⚠️ ${F} $*"; }
erro()  { echo -e "  ${R}❌${F} $*"; }

# docker exec com limite de tempo: um servico travado nao pendura a conferencia
# (onde nao existe o comando `timeout`, roda sem o limite)
if command -v timeout >/dev/null 2>&1; then
  dex() { timeout "${LIMITE:-20}" docker exec "$@" 2>/dev/null; }
else
  dex() { docker exec "$@" 2>/dev/null; }
fi

# estado do container: running, exited, ausente...
estado() { docker inspect -f '{{.State.Status}}' "$1" 2>/dev/null || echo "ausente"; }
no_ar()  { [ "$(estado "$1")" = "running" ]; }

# ------------------------------------------------------------- PostgreSQL
# roda uma consulta e devolve so o valor. $2 = banco (liga_sudoers ou airflow)
oltp() { dex postgres_oltp psql -X -q -At -U sudoers -d "${2:-liga_sudoers}" -c "$1"; }
olap() { dex postgres_olap psql -X -q -At -U sudoers -d liga_sudoers_dw -c "$1"; }
oltp_v() { [ "$(oltp "$1" "${2:-liga_sudoers}")" = "t" ]; }

# ------------------------------------------------------------------ MinIO
# O alias vai por variavel de ambiente: nao depende do `mc alias set local`
# que voce faz na trilha, nem mexe nele.
mc_() { dex -e MC_HOST_c=http://sudoers123:sudoers1234@localhost:9000 minio mc "$@"; }

# o bucket existe?
bucket() { mc_ ls c/ | awk '{print $NF}' | grep -qx "$1/"; }

# ha algum objeto (ou pasta) neste caminho? ex.: tem_objetos raw/dim_pessoas
tem_objetos() { [ -n "$(mc_ ls "c/$1/" | head -1)" ]; }

# quantas pastas/arquivos ha neste caminho
conta_objetos() { mc_ ls "c/$1/" | wc -l | tr -d ' '; }

# e uma tabela Delta? (tem o log de transacoes)
tabela_delta() { [ -n "$(mc_ ls "c/$1/_delta_log/" | grep '\.json$' | head -1)" ]; }

# operacoes registradas no log de uma tabela Delta, uma por linha
operacoes_delta() {
  local f
  for f in $(mc_ ls "c/$1/_delta_log/" | awk '{print $NF}' | grep '^[0-9]*\.json$'); do
    mc_ cat "c/$1/_delta_log/$f" | grep -o '"operation":"[^"]*"' | head -1 | cut -d'"' -f4
  done
}

# -------------------------------------------------------- Debezium / Kafka
# estado de um conector do Kafka Connect: RUNNING, FAILED, AUSENTE...
# So vale RUNNING se o conector E a tarefa dele estiverem rodando.
conector() {
  local r
  r=$(dex debezium curl -s -m 8 "http://localhost:8083/connectors/$1/status")
  case "$r" in
    "")                echo "SEM_RESPOSTA" ;;
    *'"error_code"'*)  echo "AUSENTE" ;;
    *)
      local estados
      estados=$(echo "$r" | grep -o '"state":"[A-Z_]*"' | cut -d'"' -f4 | sort -u | tr '\n' ' ')
      case "$estados" in
        "RUNNING ") [ "$(echo "$r" | grep -o '"state"' | wc -l)" -ge 2 ] && echo "RUNNING" || echo "SEM_TAREFA" ;;
        *FAILED*)   echo "FAILED" ;;
        *)          echo "${estados% }" ;;
      esac ;;
  esac
}

topico() { dex kafka kafka-topics --bootstrap-server kafka:9092 --list | grep -qx "$1"; }

# total de mensagens ja publicadas num topico (soma das particoes)
mensagens() {
  dex kafka kafka-run-class kafka.tools.GetOffsetShell --bootstrap-server kafka:9092 --topic "$1" \
    | awk -F: '{s += $3} END {print s + 0}'
}
