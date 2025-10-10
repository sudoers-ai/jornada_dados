{{ config(    
    partition_by=['dt_venda'],
    materialized='incremental', 
    unique_key=['id_pedido', 'id_pessoa', 'id_produto'], 
    incremental_strategy='merge'

) }}
WITH orders AS (
    SELECT 
        p.id AS id_pedido, 
        p.id_pessoa, 
        i.id_produto, 
        a.dispositivo, 
        a.geohash,
        a.telefone,
        p.dt_venda,
        i.qtde, 
        i.valor_total AS valor_unit,
        p.valor_total, 
        p.created_at,
        p.updated_at
    FROM {{ source('bronze', 'pedidos') }} p 
        INNER JOIN {{ source('bronze', 'itens_pedidos') }} i 
        ON p.id = i.id_pedido 
        INNER JOIN {{ source('bronze', 'auditoria_pedidos') }} a 
        ON p.id = a.id_pedido
    {% if is_incremental() %}
        -- Pega apenas registros que foram atualizados após o último update da tabela
        WHERE 
            p.updated_at >
      (
        SELECT COALESCE(MAX(updated_at), TIMESTAMP '1970-01-01 00:00:00')
        FROM {{ this }}
      )
    {% endif %}

)

SELECT * FROM orders;







