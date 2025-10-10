{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['id_pedido', 'id_pessoa', 'id_produto', 'dt_venda'],
    partition_by=['dt_venda']
) }}

{% if is_incremental() %}
-- último updated_at já carregado na TABELA DE DESTINO ({{ this }})
with last_run as (
  select coalesce(max(updated_at), timestamp '1970-01-01 00:00:00') as max_updated
  from {{ this }}
),itens_person as (
{% endif %}

  select
      dp.nome,
      dp.sexo,
      dp.dt_nasc,
      dpr.cat_desc,
      dpr.descricao,
      fp.id_pedido,
      fp.id_pessoa,
      fp.id_produto,
      fp.dt_venda,
      fp.dispositivo,
      fp.geohash,
      coalesce(fp.valor_unit, 0) as total,
      fp.updated_at                      
  from {{ source('silver','fato_pedidos') }} fp
  join {{ source('silver','dim_produtos') }} dpr on dpr.id = fp.id_produto
  join {{ source('silver','dim_pessoas') }}  dp  on dp.id = fp.id_pessoa
  {% if is_incremental() %}
  where fp.updated_at > (select max_updated from last_run)
)
select * from itens_person;
  {% endif %}

