# frozen_string_literal: true

require_relative "../lib/fahrenheit_to_celsius_converter"

class TestRunner
  include FahrenheitToCelsiusConverter
  def run_tests
    puts convert_fahrenheit_to_celsius(100)
  end
end

TestRunner.new.run_tests
