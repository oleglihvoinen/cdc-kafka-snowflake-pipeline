# CDC Kafka Snowflake Pipeline

An end-to-end reference architecture for **change data capture (CDC)** from PostgreSQL into an event-driven analytical platform.

## Flow
PostgreSQL WAL → Debezium → Kafka topics → Snowflake RAW event storage → dbt staging/current-state models → analytics.

## Included
- local PostgreSQL + Kafka + Debezium environment with Docker Compose
- sample commerce tables and data
- Debezium PostgreSQL connector definition
- Snowflake raw-event table design retaining Kafka topic/partition/offset metadata
- dbt staging model for Debezium event envelopes
- incremental current-state model
- CI validation of Compose and connector JSON

The local repository demonstrates the CDC source/streaming side directly. Snowflake is a downstream integration point and requires external credentials/services.

## Why this matters
CDC avoids repeated full-table extracts, captures inserts/updates/deletes as events, preserves change history and creates a foundation for near-real-time analytical models and multiple independent consumers.

**Technologies:** PostgreSQL · WAL · Debezium · Apache Kafka · Docker Compose · Snowflake · dbt · SQL · CDC · event streaming
