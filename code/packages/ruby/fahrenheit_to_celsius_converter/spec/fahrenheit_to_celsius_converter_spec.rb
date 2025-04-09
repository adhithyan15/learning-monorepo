# frozen_string_literal: true

RSpec.describe FahrenheitToCelsiusConverter do
  include FahrenheitToCelsiusConverter

  it "has a version number" do
    expect(FahrenheitToCelsiusConverter::VERSION).not_to be nil
  end

  it "converts 32F to 0C" do
    expect(convert_fahrenheit_to_celsius(32)).to eq(0)
  end

  it "converts 212F to 100C" do
    expect(convert_fahrenheit_to_celsius(212)).to eq(100)
  end

  it "converts 57F to 13.8C" do
    expect(convert_fahrenheit_to_celsius(57)).to be_within(0.001).of(13.888)
  end
end
