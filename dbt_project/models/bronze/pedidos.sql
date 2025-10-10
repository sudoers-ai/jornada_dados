{{ config(    
    partition_by=['created_at'],
    materialized='incremental', 
    unique_key=['id'], 
    incremental_strategy='merge'
) }}
-- models/pedidos.sql
WITH source_data AS (
    SELECT * 
    FROM oltp.pedidos
)

SELECT 
    id_pessoa,
    id,
    CAST(dt_venda as DATE) as dt_venda,
    COALESCE(valor_total, 0) AS valor_total,
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
