import pytest

from shipping.api import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as c:
        yield c


def test_health(client):
    r = client.get("/health")
    assert r.status_code == 200
    assert r.get_json()["status"] == "ok"


def test_rates(client):
    r = client.get("/rates")
    assert r.status_code == 200
    assert "standard" in r.get_json()["rates"]


def test_quote(client):
    r = client.post("/quote", json={"weight_kg": 10, "tier": "express"})
    assert r.status_code == 200
    assert r.get_json()["cost"] == 150.0


def test_quote_minimum(client):
    r = client.post("/quote", json={"weight_kg": 0.5})
    assert r.get_json()["cost"] == 10.0


def test_quote_bad_tier(client):
    r = client.post("/quote", json={"weight_kg": 1, "tier": "teleport"})
    assert r.status_code == 400


def test_quote_missing_weight(client):
    r = client.post("/quote", json={})
    assert r.status_code == 400