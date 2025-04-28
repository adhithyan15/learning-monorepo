class MemoryProcessor
  attr_reader :logs

  def initialize
      @logs = []
  end

  def process(level:, message:)
      @logs << { level: level, message: message }
  end
end