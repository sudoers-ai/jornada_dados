# Proposta de “Área de Desafios” por nível

> **Objetivo:** oferecer trilhas progressivas sem mexer no código. Cada nível tem **tarefas**, **evidências** (o que comprova que deu certo) e **entregáveis** (o que o aluno posta/commita).


## Seção “Desafios” (para o README)

# 🧪 Desafios da Jornada

Escolha seu nível. Cada desafio tem **tarefas**, **evidências** (o que comprova que deu certo) e **entregáveis** (o que você vai postar/commitar). **Não é necessário alterar nenhum código do projeto**.

- [Nível Júnior](#nível-júnior) — ponta a ponta funcional (base)
- [Nível Pleno](#nível-pleno) — CDC, orquestração e qualidade
- [Nível Sênior](#nível-sênior) — confiabilidade, performance e governança

> **Dica:** conclua o Júnior antes, mesmo que você seja avançado. Isso garante que todo o ambiente está consistente.

## 🔹 Nível Júnior — “Ponta a ponta funcional (base)”

**Foco:** subir a stack, gerar dados, validar camadas e ver fraude aparecer.

**Tarefas**

1. Subir a stack com `docker compose up --build`.
2. Criar buckets `raw/trusted/refined` e deixá-los públicos.
3. Rodar `liga_sudoers_historico.py` e confirmar arquivos/linhas novas.
4. Rodar `liga_sudoers_streaming.py` e confirmar chegada contínua.
5. Executar DBT e verificar materializações no DW.
6. Ler dados no Spark (read simples) e confirmar schema + count.
7. Validar regras de fraude (geohash fora de SP/MG/RJ e troca de device).

**Evidências mínimas**

* Screenshot da UI do MinIO com `raw/trusted/refined` e objetos recentes.
* Trecho do `dbt.log` com “completed successfully”.
* Saída de CLI (ou print) com contagem de linhas em `refined`.
* 2 exemplos de registros marcados como fraude (um por regra).

**Entregáveis**

* `CHECKLIST_JUNIOR.md` (modelo pronto que eu te entrego).
* 3–5 prints com legendas (“o que estou provando aqui?”).


---

## 🔸 Nível Pleno — “CDC, orquestração e qualidade”

**Foco:** CDC funcional, transformação incremental e uma orquestração simples.

**Tarefas**

1. Validar Debezium publicando em Kafka (gerar alteração real no Postgres e ver o evento).
2. Criar **um modelo dbt incremental** simples (sem alterar o que já existe) e adicionar **um teste** (ex.: `not null` ou `unique` em chave).
3. Orquestrar **um mini-pipeline no Airflow**: ingestão → dbt → checagem (dummy/sensor).
4. Expor uma **consulta de taxa de fraude por UF** (pode ser SQL simples no DW).
5. Documentar **pontos de falha** e **recuperação** (ex.: “se Kafka cair, o que reprocesso?”).

**Evidências mínimas**

* Log do conector Debezium “RUNNING” e tópico com mensagens novas.
* Resultado do `dbt test` com sucesso.
* DAG no Airflow “verde” (print da execução).
* Resultado da consulta (tabela pequena com UF vs % fraude).

**Entregáveis**

* `RELATORIO_PLENO.md` com:

  * Passos executados
  * Evidências (prints)
  * Consulta usada
  * 3 riscos + plano de mitigação curto

---

## 🟣 Nível Sênior — “Confiabilidade, performance e governança”

**Foco:** robustez, reprocessamento e boas práticas de DataOps.

**Tarefas**

1. Otimizar um job Spark (ex.: particionamento e/ou `checkpointing`) **sem alterar lógica de negócio**. Documentar trade-offs.
2. Introduzir **verificações de qualidade** no fluxo (ex.: contagem mínima por partição, ou expectativas simples antes de promover `trusted → refined`).
3. Especificar (em Markdown) um **plano de reprocessamento** e **exactly-once-like** (nível conceitual + passos operacionais com o que temos).
4. Propor (em Markdown) uma **estratégia SCD Tipo 2** para 1 dimensão (sem mexer no código do aluno): desenho, colunas técnicas, impacto no dbt.
5. Esboçar indicadores de **observabilidade** (ex.: latência por estágio, % de linhas inválidas, falhas por DAG).

**Evidências mínimas**

* Print/trecho de log do Spark mostrando particionamento/throughput melhor (ou justificativa técnica se não cabe em máquina local).
* Tabela de checagens de qualidade aplicadas e resultados.
* Documentos `.md` com os planos (reprocessamento, SCD2, observabilidade).

**Entregáveis**

* `ARQUITETURA_SENIOR.md` com:

  * Otimizações e porque
  * Plano de reprocessamento
  * SCD2 (desenho + colunas)
  * Indicadores e alarmes propostos

---


## Callouts reutilizáveis

```markdown
> **Atenção:** verifique portas e memória do Docker Desktop antes de subir a stack.
>
> **Dica:** após cada etapa, salve 1 print com legenda do que foi validado.
>
> **Verifique:** `docker compose ps` deve mostrar serviços `Up (healthy)`.
```

## Tabela “Validação por evidências”

```markdown
| Etapa                       | Como validar                          | Evidência esperada                         |
|----------------------------|----------------------------------------|--------------------------------------------|
| Stack no ar                | `docker compose ps`                    | Serviços `Up`/`healthy`                    |
| Buckets MinIO              | UI `http://localhost:9000`             | `raw`, `trusted`, `refined` visíveis       |
| Histórico gerado           | UI/CLI MinIO                           | Objetos novos em `raw/`                    |
| DBT executado              | `dbt.log`                              | `completed successfully`                   |
| Spark leu dados            | CLI/output                             | `count` > 0 e schema coerente              |
| CDC → Kafka                | logs Debezium + tópicos                | Mensagens novas no tópico                   |
| Fraude (regras)            | amostragem de registros                | 1 caso geohash fora SP/MG/RJ; 1 troca device |
```

