{{ config(materialized='incremental', unique_key=['id'], incremental_strategy='merge') }}

-- models/pessoas.sql
WITH source_data AS (
    SELECT * 
    FROM oltp.pessoas
)

SELECT 
    id,
    nome,
    sexo,
    CAST(dt_nasc AS DATE) AS dt_nasc,
    created_at,
    updated_at
FROM source_data
{% if is_incremental() %}
    -- Pega apenas registros que foram atualizados após o último update da tabela
    WHERE 
            updated_at >
      (
        SELECT COALESCE(MAX(updated_at), TIMESTAMP '1970-01-01 00:00:00')
        FROM {{ this }}
      )      
{% endif %}