{{ config(    
    materialized='incremental', 
    unique_key='id', 
    incremental_strategy='merge'
) }}

WITH cleaned_data AS (
    SELECT 
        p.id, 
        c.descricao AS cat_desc, 
        p.descricao, 
        p.created_at, 
        p.updated_at     
    FROM {{ source('bronze', 'produtos') }} p 
            INNER JOIN {{ source('bronze', 'categorias') }} c ON c.id = p.id_categoria
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

SELECT * FROM cleaned_data;




