# frozen_string_literal: true

require "spec_helper"
require_relative "../lib/fahrenheit_to_celsius_converter"

RSpec.describe FahrenheitToCelsiusConverter do
  include FahrenheitToCelsiusConverter

  describe "#convert_fahrenheit_to_celsius (edge cases)" do
    it "converts 0°F to approximately -17.78°C" do
      expect(convert_fahrenheit_to_celsius(0)).to be_within(0.01).of(-17.78)
    end

    it "converts 451°F to approximately 232.78°C" do
      expect(convert_fahrenheit_to_celsius(451)).to be_within(0.01).of(232.78)
    end

    it "handles negative Fahrenheit" do
      expect(convert_fahrenheit_to_celsius(-100)).to be_within(0.01).of(-73.33)
    end
  end
end
