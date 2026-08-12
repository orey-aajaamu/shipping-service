RATES = {
    "standard": 5.0,
    "express": 15.0,
    "overnight": 30.0,
}

MIN_CHARGE = 20.0

def calculate_shipping(weight_kg, tier="standard"):
    if tier not in RATES:
        raise ValueError(f"Unknown tier: {tier}")
    cost = weight_kg * RATES[tier]
    return max(MIN_CHARGE, cost)
