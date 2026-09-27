# CDC Kafka Snowflake Pipeline

An end-to-end **change data capture architecture** that propagates PostgreSQL changes through Debezium and Kafka into a Snowflake/dbt analytical pipeline.

![Architecture](https://raw.githubusercontent.com/oleglihvoinen/oleglihvoinen.github.io/main/assets/architecture/cdc-kafka-snowflake-pipeline.png)

## Executive summary

The pipeline replaces repeated full-table extraction with event-driven change propagation. Inserts, updates and deletes are captured from PostgreSQL WAL, emitted through Debezium into Kafka, retained with lineage metadata in Snowflake RAW storage, and transformed by dbt into typed and consumer-ready current-state models.

## Architecture

PostgreSQL WAL → Debezium → Kafka topics → Snowflake RAW event storage → dbt staging/current-state models → analytics / APIs / AI.

## Included components

- local PostgreSQL + Kafka + Debezium environment using Docker Compose
- operational customer and order tables with sample data
- Debezium PostgreSQL connector configuration
- Snowflake raw-event table retaining topic, partition and offset metadata
- dbt staging model for Debezium event envelopes
- incremental dbt model for current-state order data
- CI validation for Docker Compose and connector JSON

## Reliability and lineage

Kafka offsets provide a durable event position, while Snowflake RAW retains source event metadata for traceability, replay analysis, deduplication and idempotency controls. The transformation boundary keeps immutable change history separate from consumer-facing state.

## Enterprise hardening

A production deployment would add managed connector configuration, Schema Registry, SASL/TLS, secret management, connector monitoring, dead-letter handling, schema-evolution controls, freshness SLAs, end-to-end observability and stronger idempotency guarantees.

## Repository scope

The PostgreSQL/Kafka/Debezium side is runnable locally. Snowflake is the defined downstream integration boundary and requires environment-specific credentials and infrastructure.

**Technologies:** PostgreSQL · WAL · Debezium · Apache Kafka · Docker Compose · Snowflake · dbt · SQL · CDC · incremental ELT · event streaming
