# frozen_string_literal: true

require "spec_helper"
require_relative "../lib/fahrenheit_to_celsius_converter"

RSpec.describe FahrenheitToCelsiusConverter do
  include FahrenheitToCelsiusConverter

  describe "#convert_fahrenheit_to_celsius" do
    it "converts 32°F to 0°C" do
      expect(convert_fahrenheit_to_celsius(32)).to eq(0)
    end

    it "converts 212°F to 100°C" do
      expect(convert_fahrenheit_to_celsius(212)).to eq(100)
    end

    it "converts -40°F to -40°C" do
      expect(convert_fahrenheit_to_celsius(-40)).to eq(-40)
    end
  end
end
