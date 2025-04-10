# frozen_string_literal: true

require "spec_helper"
require_relative "../lib/fahrenheit_to_celsius_converter"

RSpec.describe FahrenheitToCelsiusConverter do
  include FahrenheitToCelsiusConverter

  describe "#convert_fahrenheit_to_celsius (fractional and numeric types)" do
    it "converts 98.6°F to approximately 37°C" do
      expect(convert_fahrenheit_to_celsius(98.6)).to be_within(0.1).of(37.0)
    end

    it "converts 0.5°F to approximately -17.5°C" do
      expect(convert_fahrenheit_to_celsius(0.5)).to be_within(0.01).of(-17.5)
    end

    it "accepts an Integer" do
      expect(convert_fahrenheit_to_celsius(100)).to be_within(0.01).of(37.78)
    end

    it "accepts a Float" do
      expect(convert_fahrenheit_to_celsius(100.0)).to be_within(0.01).of(37.78)
    end

    it "accepts a BigDecimal" do
      require "bigdecimal"
      expect(convert_fahrenheit_to_celsius(BigDecimal("100"))).to be_within(0.01).of(37.78)
    end
  end
end
