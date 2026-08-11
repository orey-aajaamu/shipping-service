import click

from shipping.rates import RATES, calculate_shipping


@click.command()
@click.argument("weight", type=float)
@click.option("--tier", default="standard", type=click.Choice(sorted(RATES)))
def main(weight, tier):
    """Calculate shipping cost for WEIGHT kilograms."""
    click.echo(f"{calculate_shipping(weight, tier):.2f}")