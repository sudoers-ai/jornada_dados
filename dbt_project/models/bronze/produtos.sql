{{ config(materialized='incremental', unique_key=['id'], incremental_strategy='merge') }}
-- models/produtos.sql
WITH source_data AS (
    SELECT * 
    FROM oltp.produtos
)

SELECT 
    id_categoria,
    id,
    descricao,
    COALESCE(valor_unit, 0) AS valor_unit,
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



