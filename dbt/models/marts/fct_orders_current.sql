{{ config(materialized='incremental', unique_key='order_id', incremental_strategy='merge') }}

with candidate_events as (
  select *
  from {{ ref('stg_order_events') }}
  {% if is_incremental() %}
    -- A bounded lookback allows replay of late-arriving events. Latest source LSN
    -- and Kafka offset determine state, so reprocessing remains idempotent.
    where ingested_at >= dateadd(
      hour, -2,
      (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }})
    )
  {% endif %}
),
ranked as (
  select *,
    row_number() over (
      partition by order_id
      order by coalesce(source_lsn, 0) desc, event_ts_ms desc, kafka_offset desc
    ) as rn
  from candidate_events
)
select
  order_id,
  customer_id,
  status,
  net_revenue,
  operation,
  source_lsn,
  event_ts_ms,
  kafka_partition,
  kafka_offset,
  event_id,
  ingested_at
from ranked
where rn = 1
  and operation <> 'd'
