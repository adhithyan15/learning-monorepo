require_relative "program_error"

class InstructionIndexOutOfBoundsError < ProgramError
  def initialize(index, max_index)
    super("Instruction index #{index} is out of bounds (max: #{max_index})")
  end
end