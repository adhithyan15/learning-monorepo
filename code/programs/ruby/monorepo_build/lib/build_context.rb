require_relative 'file_processing_history'

class BuildContext
  attr_reader :file_processing_history

  def initialize
    @file_processing_history = FileProcessingHistory.new
  end
end