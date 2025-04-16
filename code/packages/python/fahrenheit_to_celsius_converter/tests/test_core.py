# tests/test_core.py

"""Tests for the core temperature conversion functions."""

import pytest  # type: ignore # Prevents mypy complaining about pytest import

# Assuming your package is installed in editable mode (-e .[dev])
# Replace 'your_package_name' with the actual package name if different
from fahrenheit_to_celsius_converter.core import fahrenheit_to_celsius

# --- Test Cases for Valid Inputs ---

# Use pytest.mark.parametrize to run the same test function with multiple inputs
@pytest.mark.parametrize(
    "temp_f, expected_c",
    [
        # Test case format: (fahrenheit_input, expected_celsius_output)

        # Standard values
        (32, 0.0),  # Freezing point of water (input as int)
        (212.0, 100.0),  # Boiling point of water (input as float)
        (98.6, 37.0),  # Approximate normal body temperature
        (-40, -40.0), # Point where scales meet (input as int)
        (0, -17.77777777777778), # Zero Fahrenheit

        # Other values
        (50, 10.0),
        (-4, -20.0),
        (68.0, 20.0), # Room temperature example

        # Value resulting in non-integer celsius
        (100, 37.77777777777778),

        # Ensure large numbers don't cause unexpected issues (within float limits)
        (1000.0, 537.7777777777778),
        (-1000.0, -573.3333333333334),

        # Test absolute zero approx (-459.67 F)
        (-459.67, -273.15),
    ],
    ids=[ # Optional: Provide IDs for better test reporting
        "freezing_point_int",
        "boiling_point_float",
        "body_temp_float",
        "scales_meet_int",
        "zero_fahrenheit_int",
        "fifty_fahrenheit_int",
        "minus_four_fahrenheit_int",
        "room_temp_float",
        "one_hundred_fahrenheit_int",
        "large_positive_float",
        "large_negative_float",
        "absolute_zero_approx_float",
    ]
)
def test_fahrenheit_to_celsius_valid_inputs(temp_f: float | int, expected_c: float):
    """
    Tests the fahrenheit_to_celsius function with various valid numeric inputs.
    """
    # Use pytest.approx for floating-point comparisons to handle tiny precision differences
    assert fahrenheit_to_celsius(temp_f) == pytest.approx(expected_c)


# --- Test Cases for Invalid Input Types ---

@pytest.mark.parametrize(
    "invalid_input",
    [
        "string",       # String
        "32",           # String that looks like a number
        None,           # NoneType
        [32],           # List
        {"temp": 32},   # Dictionary
        (32, 0),        # Tuple
        True,           # Boolean (although bool is subclass of int, often good to test explicitly)
        False,
        # Add other non-numeric types if relevant
        # complex(1, 2), # Example: Complex numbers (if they shouldn't be allowed)
    ],
    ids=[ # Optional IDs
        "string_abc",
        "string_digits",
        "none",
        "list",
        "dict",
        "tuple",
        "bool_true",
        "bool_false",
        # "complex",
    ]
)
def test_fahrenheit_to_celsius_invalid_types(invalid_input: any):
    """
    Tests that fahrenheit_to_celsius raises TypeError for non-numeric inputs.
    """
    # Use pytest.raises as a context manager to assert that an exception is raised
    with pytest.raises(TypeError) as excinfo:
        fahrenheit_to_celsius(invalid_input) # type: ignore

    # Optional: Check the exception message contains expected text
    assert "must be a number" in str(excinfo.value)