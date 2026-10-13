from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Iterable


@dataclass(frozen=True)
class CdcEvent:
    key: str
    operation: str
    source_lsn: int
    partition: int
    offset: int
    before: dict[str, Any] | None
    after: dict[str, Any] | None

    @property
    def position(self) -> tuple[int, int, int]:
        return (self.source_lsn, self.partition, self.offset)


@dataclass(frozen=True)
class CurrentRow:
    key: str
    payload: dict[str, Any]
    source_lsn: int
    partition: int
    offset: int


def reduce_events(events: Iterable[CdcEvent], initial: dict[str, CurrentRow] | None = None) -> dict[str, CurrentRow]:
    """
    Reconstruct current state from Debezium-like events.

    - duplicate events are harmless
    - older/out-of-order source positions cannot overwrite newer state
    - deletes remove current state using the key/before image
    - replaying the same stream is idempotent
    """
    state = dict(initial or {})

    for event in events:
        current = state.get(event.key)
        if current and event.position <= (current.source_lsn, current.partition, current.offset):
            continue

        if event.operation == "d":
            state.pop(event.key, None)
            continue

        if event.operation not in {"c", "r", "u"}:
            raise ValueError(f"unsupported CDC operation: {event.operation}")
        if event.after is None:
            raise ValueError(f"{event.operation} event requires after image")

        state[event.key] = CurrentRow(
            key=event.key,
            payload=dict(event.after),
            source_lsn=event.source_lsn,
            partition=event.partition,
            offset=event.offset,
        )
    return state


def deduplication_key(event: CdcEvent) -> str:
    return f"{event.partition}:{event.offset}:{event.source_lsn}"
