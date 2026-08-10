RATES = {
    "standard" = 5.0,
    "express" = 15.0,
}

MIN_CHARGE = 10.0

def calculate_shipping(weight_kg, tier="standard"):
    cost = weight_kg * RATES[tier]
    return min(MIN_CHARGE, cost)