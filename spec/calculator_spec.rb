require "spec_helper"
require "calculator"

RSpec.describe Calculator do
  describe "#add" do
    it "returns the sum of two arguments" do
      expect(Calculator.new.add(1, 2)).to eq(3)
    end

    it "returns the sum of four arguments" do
      expect(Calculator.new.add(1, 2, 3, 4)).to eq(10)
    end

    numbers = (0..50).to_a.shuffle!
    expected_values = {}
    while numbers.size >= 2
      values = numbers.pop(2)
      result = values.sum
      expected_values[values] = result
    end

    expected_values.each do |val, expected|
      it "returns #{expected} when numbers are #{val}" do
        expect(Calculator.new.add(*val)).to eq(expected)
      end
    end
  end

  describe "#subtract" do
    it "returns the result of two arguments" do
      expect(Calculator.new.subtract(1, 2)).to eq(-1)
    end
  end
end
