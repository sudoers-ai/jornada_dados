from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
}

with DAG(
    dag_id="dbt_run_dag",
    default_args=default_args,
    description="Executa o fluxo do DBT",
    schedule_interval=None,
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["dbt", "etl"],
) as dag:

    dbt_bronze = BashOperator(
        task_id="dbt_bronze",
        bash_command=r"""
    docker exec \
      -e DBT_SCHEMA=bronze \
      -e DBT_LOG_PATH=/tmp/dbt_logs/dbt.log \
      spark bash -lc '
        set -euo pipefail
        mkdir -p /tmp/dbt_logs /tmp/target
        export PATH="/.local/bin:$PATH"
        dbt run \
          --select models/bronze \
          --project-dir /usr/app \
          --profiles-dir /usr/app \
          --log-path /tmp/dbt_logs/dbt.log \
          --target-path /tmp/target
      '
    """,
    )

    dbt_silver = BashOperator(
        task_id="dbt_silver",
        bash_command=r"""
    docker exec \
      -e DBT_SCHEMA=silver \
      -e DBT_LOG_PATH=/tmp/dbt_logs/dbt.log \
      spark bash -lc '
        set -euo pipefail
        mkdir -p /tmp/dbt_logs /tmp/target
        export PATH="/.local/bin:$PATH"
        dbt run \
          --select models/silver \
          --project-dir /usr/app \
          --profiles-dir /usr/app \
          --log-path /tmp/dbt_logs/dbt.log \
          --target-path /tmp/target
      '
    """,
    )

    dbt_gold = BashOperator(
        task_id="dbt_gold",
        bash_command=r"""
    docker exec \
      -e DBT_SCHEMA=gold \
      -e DBT_LOG_PATH=/tmp/dbt_logs/dbt.log \
      spark bash -lc '
        set -euo pipefail
        mkdir -p /tmp/dbt_logs /tmp/target
        export PATH="/.local/bin:$PATH"
        dbt run \
          --select models/gold \
          --project-dir /usr/app \
          --profiles-dir /usr/app \
          --log-path /tmp/dbt_logs/dbt.log \
          --target-path /tmp/target
      '
    """,
    )

    dbt_bronze >> dbt_silver >> dbt_gold
