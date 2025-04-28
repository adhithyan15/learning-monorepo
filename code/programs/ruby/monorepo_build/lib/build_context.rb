require_relative "file_processing_history"

class BuildContext
  attr_reader :file_processing_history

  def initialize(file_processing_history:)
    @file_processing_history = file_processing_history
  end
end
