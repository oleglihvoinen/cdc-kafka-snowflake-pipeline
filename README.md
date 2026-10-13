# CDC with Debezium, Kafka & Snowflake

An end-to-end CDC architecture focused on **change correctness and replay**, not only message transport.

![Architecture](https://raw.githubusercontent.com/oleglihvoinen/oleglihvoinen.github.io/main/assets/architecture/cdc-kafka-snowflake-pipeline.png)

## Architecture

PostgreSQL WAL → Debezium → Kafka → Snowflake RAW event history → dbt typed events → replay-safe current state → analytics / APIs / AI.

## Implemented engineering depth

- runnable PostgreSQL + Kafka + Debezium Docker environment
- logical replication / WAL-based capture
- connector configuration for customer/order tables
- Snowflake RAW event design
- before- and after-image handling
- delete-aware staging
- source LSN, event timestamp, Kafka partition and offset lineage
- deterministic event identity
- delete-correct current-state view reconstructed from immutable event history
- production Snowflake MERGE pattern with explicit DELETE handling and source-position checks
- Python CDC reducer modeling duplicates, out-of-order events, deletes and replay
- automated correctness tests
- CI validation for CDC semantics

## Correctness rules

The current-state layer deliberately does not assume arrival order equals source order. Source LSN and Kafka metadata are retained so older events cannot silently regress newer state. Delete events resolve the business key from the before-image because Debezium's after-image is null for deletes. The public dbt current-state model is a delete-correct view over event history; `snowflake/apply_order_cdc.sql` shows the production MERGE pattern when a materialized current-state table is required.

The public Snowflake integration remains a defined boundary and requires environment-specific credentials.

**Technologies:** PostgreSQL · WAL · Debezium · Apache Kafka · Docker Compose · Snowflake · dbt · Python · CDC · replay · idempotency · incremental ELT
