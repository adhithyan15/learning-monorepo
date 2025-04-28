require_relative "file_processing_history"
require_relative "build_context"

def get_context
  file_history = FileProcessingHistory.new
  BuildContext.new(file_processing_history: file_history)
end
