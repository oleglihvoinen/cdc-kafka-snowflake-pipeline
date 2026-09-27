create schema if not exists raw_cdc;
create table if not exists raw_cdc.order_events (
  kafka_topic varchar,
  kafka_partition integer,
  kafka_offset number,
  event_payload variant,
  ingested_at timestamp_tz default current_timestamp(),
  constraint uq_order_event unique (kafka_topic, kafka_partition, kafka_offset)
);
