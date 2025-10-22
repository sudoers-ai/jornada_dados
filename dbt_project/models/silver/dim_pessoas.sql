{{ config(    
    materialized='incremental', 
    unique_key='id', 
    incremental_strategy='merge'
) }}

WITH cleaned_data AS (
    SELECT 
        id,
        nome,
        CASE 
            WHEN sexo = 'M' THEN 'Masculino'
            WHEN sexo = 'F' THEN 'Feminino'
            ELSE 'Indefinido'
        END AS sexo,
        CAST(dt_nasc AS DATE) AS dt_nasc,
        created_at,
        updated_at
    FROM {{ source('bronze', 'pessoas') }} p
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
