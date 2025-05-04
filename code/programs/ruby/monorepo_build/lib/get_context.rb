# lib/get_context.rb
require_relative 'file_processing_history'
require_relative 'default_standard_stream_log_processor'
require_relative 'logger'
require_relative 'exit_handler'

def get_context
  log_processor = default_standard_stream_log_processor
  logger = Logger.new(log_processor)
  file_processing_history = FileProcessingHistory.new
  exit_handler = ExitHandler.new

  BuildContext.new(
    file_processing_history: file_processing_history,
    logger: logger,
    exit_handler: exit_handler
  )
end