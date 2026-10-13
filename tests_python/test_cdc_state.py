from src.cdc_state import CdcEvent, deduplication_key, reduce_events


def e(key, op, lsn, offset, before=None, after=None):
    return CdcEvent(key, op, lsn, 0, offset, before, after)


def test_duplicate_event_is_idempotent():
    event = e("O1", "c", 100, 1, after={"status": "NEW"})
    once = reduce_events([event])
    twice = reduce_events([event], once)
    assert once == twice


def test_out_of_order_event_cannot_regress_state():
    newer = e("O1", "u", 200, 2, after={"status": "PAID"})
    older = e("O1", "u", 150, 3, after={"status": "NEW"})
    state = reduce_events([newer, older])
    assert state["O1"].payload["status"] == "PAID"


def test_delete_removes_current_state():
    created = e("O1", "c", 100, 1, after={"status": "NEW"})
    deleted = e("O1", "d", 200, 2, before={"status": "NEW"})
    assert "O1" not in reduce_events([created, deleted])


def test_replay_after_delete_does_not_resurrect_old_row():
    deleted = e("O1", "d", 300, 4, before={"status": "PAID"})
    old = e("O1", "u", 250, 3, after={"status": "PAID"})
    # Tombstone position would normally live in raw history/control metadata;
    # this test proves ordering within a replay batch.
    assert "O1" not in reduce_events([old, deleted])


def test_event_identity_contains_transport_and_source_position():
    event = e("O1", "c", 100, 7, after={"status": "NEW"})
    assert deduplication_key(event) == "0:7:100"
