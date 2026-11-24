#!/usr/bin/env bash
# ==========================================================================
# Mostra os servicos e, para cada etapa da trilha, o que ja foi feito. E o
# "onde eu parei?" do comeco de cada sessao de estudo.
#
# E rapido de proposito: olha so o MinIO, o PostgreSQL e o Kafka Connect.
# O detalhe de cada etapa (com o catalogo do Spark): make conferir e=N
# ==========================================================================
set -uo pipefail
cd "$(dirname "$0")/.." && . scripts/comum.sh
marca() { if [ "$1" = t ]; then echo -ne "${V}✅${F}"; else echo -ne "${C}⬜${F}"; fi; }
sim()   { "$@" >/dev/null 2>&1 && echo t || echo f; }

echo
no_ar_n=0; linha=""
for s in $SERVICOS; do
  case "$(estado "$s")" in
    running) no_ar_n=$((no_ar_n + 1)); linha="$linha ${V}●${F} $s " ;;
    ausente) linha="$linha ${C}○${F} $s " ;;
    *)       linha="$linha ${R}●${F} $s " ;;
  esac
done
if [ "$no_ar_n" = 0 ]; then
  echo -e "  ${N}serviços${F}  ${C}nenhum no ar${F} (make subir)"; echo; exit 0
fi
echo -e "  ${N}serviços${F}  $no_ar_n de 8 no ar"
echo -e "  $linha"
[ "$no_ar_n" -lt 8 ] && echo -e "  ${C}● verde: no ar   ● vermelho: parado   ○ não criado   (make subir; motivo em make logs s=NOME)${F}"
echo

# as etapas dependem destes tres: sem eles nao ha o que mostrar
if ! no_ar minio || ! no_ar postgres_oltp; then
  echo -e "  ${A}minio e postgres_oltp precisam estar no ar para mostrar as etapas.${F}"; echo; exit 0
fi

delta_ok() {  # delta_ok bucket t1 t2 ...
  local b="$1" t; shift
  for t in "$@"; do tabela_delta "$b/$t" || return 1; done
}
af() { oltp "$1" airflow; }
conector_ok() { [ "$(conector "$1")" = RUNNING ]; }

echo -e "  ${N}0 ambiente  ${F}  $(marca "$(sim bucket raw)") bucket raw   $(marca "$(sim bucket trusted)") trusted   $(marca "$(sim bucket refined)") refined"
echo -e "  ${N}1 quickstart${F}  $(marca "$(sim tem_objetos raw/dim_pessoas)") dim_pessoas.csv no MinIO"
echo -e "  ${N}2 delta_lake${F}  $(marca "$(sim tem_objetos raw/fato_pedidos)") raw   $(marca "$(sim tem_objetos trusted/fato_pedidos)") trusted   $(marca "$(sim tem_objetos refined/itens_by_person)") refined   $(marca "$(sim delta_ok trusted dim_pessoas_delta dim_produtos_delta fato_pedidos_delta)") tabelas Delta"
if no_ar debezium && no_ar kafka; then
  echo -e "  ${N}3 debezium  ${F}  $(marca "$(sim oltp_v "SELECT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'pessoas_pub')")") publicação   $(marca "$(sim conector_ok postgres-connector-pessoas)") PostgreSQL → Kafka   $(marca "$(sim conector_ok minio-sink-connector)") Kafka → MinIO   $(marca "$(sim tem_objetos raw/topics/liga_sudoers.public.pessoas)") eventos no data lake"
else
  echo -e "  ${N}3 debezium  ${F}  ${C}kafka e debezium precisam estar no ar${F}"
fi
echo -e "  ${N}4 dbt       ${F}  $(marca "$(sim delta_ok bronze pessoas categorias produtos pedidos itens_pedidos auditoria_pedidos)") bronze   $(marca "$(sim delta_ok silver dim_pessoas dim_produtos fato_pedidos)") silver   $(marca "$(sim delta_ok gold itens_by_person)") gold"
echo -e "  ${N}5 airflow   ${F}  $(marca "$([ "$(af "SELECT count(*) FROM ab_user WHERE username = 'liga_sudoers'")" = 1 ] && echo t)") usuário   $(marca "$([ "$(af "SELECT is_paused FROM dag WHERE dag_id = 'dbt_run_dag'")" = f ] && echo t)") DAG ativa   $(marca "$([ "$(af "SELECT state FROM dag_run WHERE dag_id = 'dbt_run_dag' ORDER BY execution_date DESC LIMIT 1")" = success ] && echo t)") DAG executada"
echo
echo -e "  ${C}Detalhe de cada etapa: make conferir e=0 (ou 1, 2, 3, 4, 5)${F}"
echo
