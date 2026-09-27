{{ config(materialized='incremental', unique_key='order_id', incremental_strategy='merge') }}
with ranked as (
  select *, row_number() over(partition by order_id order by kafka_offset desc) rn
  from {{ ref('stg_order_events') }}
  {% if is_incremental() %}
  where ingested_at > (select coalesce(max(ingested_at),'1900-01-01') from {{ this }})
  {% endif %}
)
select order_id, customer_id, status, net_revenue, operation, ingested_at
from ranked where rn=1 and operation <> 'd'
