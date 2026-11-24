# ==========================================================================
# Jornada Engenharia de Dados (Liga Sudoers) - atalhos
#
#   make ajuda      lista tudo
#
# Nada aqui e obrigatorio: os roteiros continuam usando `docker compose` e
# `docker exec`. O Makefile poupa digitacao e responde a duas perguntas:
# "onde eu parei?" (make status) e "fiz certo?" (make conferir e=N).
# ==========================================================================
.DEFAULT_GOAL := ajuda
SHELL := /bin/bash
DC    := docker compose

.PHONY: ajuda subir parar status conferir logs

ajuda:  ## mostra esta ajuda
	@echo ""
	@echo "  Jornada Engenharia de Dados - Liga Sudoers"
	@echo "  ---------------------------------------------------------------"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[1m%-10s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "  Etapas do make conferir: 0 ambiente, 1 quickstart, 2 delta_lake,"
	@echo "  3 debezium, 4 dbt, 5 airflow"
	@echo ""

subir:       ## sobe os 8 servicos em segundo plano (retoma de onde parou)
	$(DC) up -d
	@echo ""
	@echo "  Servicos subindo. Debezium e Airflow levam cerca de 1 minuto."
	@echo "  Veja onde voce parou com: make status"
	@echo ""

parar:       ## para os servicos (MANTEM os dados dos volumes)
	$(DC) stop

status:      ## mostra os servicos e o que ja foi feito em cada etapa
	@bash scripts/status.sh

conferir:    ## confere o que ja foi feito numa etapa (make conferir e=2)
	@test -n "$(e)" || (echo "uso: make conferir e=0   (a etapa: 0 ambiente, 1 quickstart, 2 delta_lake, 3 debezium, 4 dbt, 5 airflow)" && exit 1)
	@bash scripts/conferir.sh $(e)

logs:        ## mostra o log de um servico (make logs s=debezium)
	@test -n "$(s)" || (echo "uso: make logs s=debezium   (postgres_oltp, postgres_olap, minio, spark, zookeeper, kafka, debezium, airflow)" && exit 1)
	@docker logs --tail 80 $(s)
