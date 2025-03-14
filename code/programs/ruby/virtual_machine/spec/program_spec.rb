require_relative '../program'
require_relative "../errors/program/instruction_index_out_of_bounds_error"
require 'rspec'

RSpec.describe Program do
  let(:instructions) { [1, 2, 3, 99] }
  let(:program) { Program.new(instructions) }

  describe "#initialize" do
    it "stores the given instructions" do
      expect(program.instructions).to eq(instructions)
    end
  end

  describe "#instruction_at" do
    it "returns the instruction at the given index" do
      expect(program.instruction_at(0)).to eq(1)
      expect(program.instruction_at(2)).to eq(3)
    end

    it "returns errors for out-of-bounds indices" do
      expect { program.instruction_at(-1) }.to raise_error(InstructionIndexOutOfBoundsError)
      expect { program.instruction_at(10) }.to raise_error(InstructionIndexOutOfBoundsError)
    end
  end

  describe "#size" do
    it "returns the correct number of instructions" do
      expect(program.size).to eq(4)
    end
  end
end