-- Production-oriented Snowflake current-state application pattern.
-- The staging relation must expose one latest CDC event per business key.
-- DELETE is handled explicitly rather than filtering the source row away.

merge into ANALYTICS.CURATED.ORDERS_CURRENT t
using (
    select *
    from ANALYTICS.STAGING.ORDER_EVENTS_LATEST
) s
on t.order_id = s.order_id

when matched and s.operation = 'd' then delete

when matched and s.operation in ('c', 'r', 'u')
  and (
      coalesce(s.source_lsn, 0) > coalesce(t.source_lsn, 0)
      or (
          coalesce(s.source_lsn, 0) = coalesce(t.source_lsn, 0)
          and s.kafka_offset > t.kafka_offset
      )
  )
then update set
    customer_id = s.customer_id,
    status = s.status,
    net_revenue = s.net_revenue,
    source_lsn = s.source_lsn,
    event_ts_ms = s.event_ts_ms,
    kafka_partition = s.kafka_partition,
    kafka_offset = s.kafka_offset,
    event_id = s.event_id,
    ingested_at = s.ingested_at

when not matched and s.operation in ('c', 'r', 'u') then insert (
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
) values (
    s.order_id,
    s.customer_id,
    s.status,
    s.net_revenue,
    s.source_lsn,
    s.event_ts_ms,
    s.kafka_partition,
    s.kafka_offset,
    s.event_id,
    s.ingested_at
);
