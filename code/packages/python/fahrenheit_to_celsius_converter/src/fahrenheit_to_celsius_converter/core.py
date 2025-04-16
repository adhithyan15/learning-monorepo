"""Core conversion logic for temperature."""

# Import the 'typing' module for more complex types if needed later,
# but for basic types like float, it's not strictly required.
# from typing import Union # Example if needed

def fahrenheit_to_celsius(temp_f: float) -> float:
    """
    Converts a temperature from Fahrenheit to Celsius.

    Args:
        temp_f: The temperature in degrees Fahrenheit.

    Returns:
        The equivalent temperature in degrees Celsius.

    Raises:
        TypeError: If the input is not a number (int or float).
    """
     # Explicitly check for bool type first, as bool is a subclass of int
    if isinstance(temp_f, bool):
        # You could raise ValueError too, but TypeError aligns with "wrong type"
        raise TypeError("Input temperature cannot be a boolean.")

    # Check if the input is an integer or a float
    if not isinstance(temp_f, int | float):
        raise TypeError("Input temperature must be a number (int or float).")

    # Perform the conversion using floating-point division
    celsius = (temp_f - 32.0) * 5.0 / 9.0
    return celsius
