import pytest

from shipping.rates import calculate_shipping


def test_standard_rate():
    assert calculate_shipping(10) == 50.0


def test_minimum_charge_applies():
    assert calculate_shipping(0.5) == 12.0


def test_unknown_tier_rejected():
    with pytest.raises(ValueError):
        calculate_shipping(10, "teleport")