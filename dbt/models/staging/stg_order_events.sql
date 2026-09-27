select
  event_payload:payload:after:order_id::number as order_id,
  event_payload:payload:after:customer_id::number as customer_id,
  event_payload:payload:after:status::varchar as status,
  event_payload:payload:after:net_revenue::number(12,2) as net_revenue,
  event_payload:payload:op::varchar as operation,
  kafka_partition, kafka_offset, ingested_at
from {{ source('raw_cdc', 'order_events') }}
