{{ config(materialized='view') }}

with ranked as (
  select *,
    row_number() over (
      partition by order_id
      order by coalesce(source_lsn, 0) desc, event_ts_ms desc, kafka_offset desc
    ) as rn
  from {{ ref('stg_order_events') }}
)
select
  order_id,
  customer_id,
  status,
  net_revenue,
  source_lsn,
  event_ts_ms,
  kafka_partition,
  kafka_offset,
  event_id,
  ingested_at
from ranked
where rn = 1
  and operation <> 'd'
