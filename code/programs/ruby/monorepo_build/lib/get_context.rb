require_relative 'file_processing_history'
require_relative 'build_context'
require_relative 'logger'

def get_context
  file_history = FileProcessingHistory.new
  logger = Logger.new
  BuildContext.new(file_processing_history: file_history, logger: logger)
end