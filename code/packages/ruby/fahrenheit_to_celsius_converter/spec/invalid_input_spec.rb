# frozen_string_literal: true

require "spec_helper"
require_relative "../lib/fahrenheit_to_celsius_converter"

RSpec.describe FahrenheitToCelsiusConverter do
  include FahrenheitToCelsiusConverter

  describe "#convert_fahrenheit_to_celsius (invalid input)" do
    it "raises TypeError for nil" do
      expect { convert_fahrenheit_to_celsius(nil) }.to raise_error(TypeError)
    end

    it "raises TypeError for a string" do
      expect { convert_fahrenheit_to_celsius("hello") }.to raise_error(TypeError)
    end
  end
end
