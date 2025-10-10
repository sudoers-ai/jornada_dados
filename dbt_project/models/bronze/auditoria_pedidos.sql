{{ config(    
    partition_by=['created_at'],
    materialized='incremental', 
    unique_key=['id_pedido'], 
    incremental_strategy='merge'    
) }}
-- models/auditoria_pedidos.sql
WITH source_data AS (
    SELECT * 
    FROM oltp.auditoria_pedidos
)

SELECT 
    id_pedido,
    dispositivo,
    geohash,
    telefone,
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

