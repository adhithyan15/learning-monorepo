import unittest

# Make sure this package name matches your project's package name
from fahrenheit_to_celsius_converter.core import fahrenheit_to_celsius

class TestFahrenheitToCelsius(unittest.TestCase):
    """Test suite for the fahrenheit_to_celsius function."""

    # --- Test Cases for Valid Inputs (One method per case) ---

    def test_f_to_c_valid_freezing_point_int(self):
        """Tests F to C conversion at freezing point (32 F -> 0 C)."""
        self.assertAlmostEqual(fahrenheit_to_celsius(32), 0.0, places=7)

    def test_f_to_c_valid_boiling_point_float(self):
        """Tests F to C conversion at boiling point (212 F -> 100 C)."""
        self.assertAlmostEqual(fahrenheit_to_celsius(212.0), 100.0, places=7)

    def test_f_to_c_valid_body_temp_float(self):
        """Tests F to C conversion at body temperature (98.6 F -> 37 C)."""
        self.assertAlmostEqual(fahrenheit_to_celsius(98.6), 37.0, places=7)

    def test_f_to_c_valid_scales_meet_int(self):
        """Tests F to C conversion where scales meet (-40 F -> -40 C)."""
        self.assertAlmostEqual(fahrenheit_to_celsius(-40), -40.0, places=7)

    def test_f_to_c_valid_zero_fahrenheit_int(self):
        """Tests F to C conversion for 0 Fahrenheit."""
        self.assertAlmostEqual(fahrenheit_to_celsius(0), -17.7777778, places=7)

    def test_f_to_c_valid_fifty_fahrenheit_int(self):
        """Tests F to C conversion for 50 Fahrenheit."""
        self.assertAlmostEqual(fahrenheit_to_celsius(50), 10.0, places=7)

    def test_f_to_c_valid_minus_four_fahrenheit_int(self):
        """Tests F to C conversion for -4 Fahrenheit."""
        self.assertAlmostEqual(fahrenheit_to_celsius(-4), -20.0, places=7)

    def test_f_to_c_valid_room_temp_float(self):
        """Tests F to C conversion for room temperature (68 F -> 20 C)."""
        self.assertAlmostEqual(fahrenheit_to_celsius(68.0), 20.0, places=7)

    def test_f_to_c_valid_one_hundred_fahrenheit_int(self):
        """Tests F to C conversion for 100 Fahrenheit."""
        self.assertAlmostEqual(fahrenheit_to_celsius(100), 37.7777778, places=7)

    def test_f_to_c_valid_large_positive_float(self):
        """Tests F to C conversion for a large positive temperature."""
        self.assertAlmostEqual(fahrenheit_to_celsius(1000.0), 537.7777778, places=7)

    def test_f_to_c_valid_large_negative_float(self):
        """Tests F to C conversion for a large negative temperature."""
        self.assertAlmostEqual(fahrenheit_to_celsius(-1000.0), -573.3333333, places=7)

    def test_f_to_c_valid_absolute_zero_approx_float(self):
        """Tests F to C conversion for approximate absolute zero (-459.67 F -> -273.15 C)."""
        self.assertAlmostEqual(fahrenheit_to_celsius(-459.67), -273.15, places=7)

    # --- Test Cases for Invalid Input Types (One method per case, checks Type Only) ---

    def test_f_to_c_invalid_input_string_abc(self):
        """Tests F to C raises TypeError for a generic string."""
        with self.assertRaises(TypeError):
            fahrenheit_to_celsius("string") # type: ignore

    def test_f_to_c_invalid_input_string_digits(self):
        """Tests F to C raises TypeError for a string containing digits."""
        with self.assertRaises(TypeError):
            fahrenheit_to_celsius("32") # type: ignore

    def test_f_to_c_invalid_input_none(self):
        """Tests F to C raises TypeError for None input."""
        with self.assertRaises(TypeError):
            fahrenheit_to_celsius(None) # type: ignore

    def test_f_to_c_invalid_input_list(self):
        """Tests F to C raises TypeError for list input."""
        with self.assertRaises(TypeError):
            fahrenheit_to_celsius([32]) # type: ignore

    def test_f_to_c_invalid_input_dict(self):
        """Tests F to C raises TypeError for dict input."""
        with self.assertRaises(TypeError):
            fahrenheit_to_celsius({"temp": 32}) # type: ignore

    def test_f_to_c_invalid_input_tuple(self):
        """Tests F to C raises TypeError for tuple input."""
        with self.assertRaises(TypeError):
            fahrenheit_to_celsius((32, 0)) # type: ignore

    def test_f_to_c_invalid_input_bool_true(self):
        """Tests F to C raises TypeError for boolean True input."""
        with self.assertRaises(TypeError):
            fahrenheit_to_celsius(True) # type: ignore

    def test_f_to_c_invalid_input_bool_false(self):
        """Tests F to C raises TypeError for boolean False input."""
        with self.assertRaises(TypeError):
            fahrenheit_to_celsius(False) # type: ignore

    # def test_f_to_c_invalid_input_complex(self):
    #     """Tests F to C raises TypeError for complex number input."""
    #     with self.assertRaises(TypeError):
    #         fahrenheit_to_celsius(complex(1, 2)) # type: ignore


# --- Placeholder for tests of other functions ---

# class TestCelsiusToFahrenheit(unittest.TestCase):
#     # Add individual test methods here
#     pass


# Allows running the tests directly using `python tests/test_core.py`
if __name__ == '__main__':
    unittest.main()