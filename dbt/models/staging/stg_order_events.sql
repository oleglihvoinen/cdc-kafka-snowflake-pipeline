with envelope as (
  select
    coalesce(
      event_payload:payload:after:order_id::number,
      event_payload:payload:before:order_id::number
    ) as order_id,
    event_payload:payload:after:customer_id::number as after_customer_id,
    event_payload:payload:before:customer_id::number as before_customer_id,
    event_payload:payload:after:status::varchar as after_status,
    event_payload:payload:before:status::varchar as before_status,
    event_payload:payload:after:net_revenue::number(12,2) as after_net_revenue,
    event_payload:payload:before:net_revenue::number(12,2) as before_net_revenue,
    event_payload:payload:op::varchar as operation,
    event_payload:payload:source:lsn::number as source_lsn,
    event_payload:payload:ts_ms::number as event_ts_ms,
    kafka_partition,
    kafka_offset,
    ingested_at
  from {{ source('raw_cdc', 'order_events') }}
)
select
  order_id,
  coalesce(after_customer_id, before_customer_id) as customer_id,
  coalesce(after_status, before_status) as status,
  coalesce(after_net_revenue, before_net_revenue) as net_revenue,
  operation,
  source_lsn,
  event_ts_ms,
  kafka_partition,
  kafka_offset,
  concat(kafka_partition, ':', kafka_offset, ':', coalesce(source_lsn, 0)) as event_id,
  ingested_at
from envelope
where order_id is not null
