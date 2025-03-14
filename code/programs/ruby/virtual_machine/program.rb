require_relative "errors/program/instruction_index_out_of_bounds_error"

class Program
  attr_reader :instructions
  
  def initialize(instructions)
    @instructions = instructions
  end

  def instruction_at(index)
    max_index = @instructions.length - 1
    raise InstructionIndexOutOfBoundsError.new(index, max_index) if index < 0 || index > max_index
    @instructions[index]
  end

  def size
    @instructions.length
  end
end