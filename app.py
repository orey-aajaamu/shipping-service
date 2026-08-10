RATES = {
    "standard" = 5.0,
    "express" = 15.0,
}

def calculate_shipping(weight_kg, teir="standard"):
    return weight_kg*RATES[teir]