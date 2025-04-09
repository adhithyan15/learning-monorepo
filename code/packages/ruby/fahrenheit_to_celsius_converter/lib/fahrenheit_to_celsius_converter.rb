# frozen_string_literal: true

require_relative "fahrenheit_to_celsius_converter/version"

# A fahrenheit to celsius conversion module
module FahrenheitToCelsiusConverter
  def convert_fahrenheit_to_celsius(temperature_value_in_fahrenheit)
    # To convert the temperature from fahrenheit to celsius, you need to
    # subtract 32 from the temperature (32F is the zero point in celsius scale)
    # and multiply by 5/9
    (5.0 / 9.0) * (temperature_value_in_fahrenheit - 32)
  end
end
