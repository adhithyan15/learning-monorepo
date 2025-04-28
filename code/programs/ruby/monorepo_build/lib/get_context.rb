require_relative 'file_processing_history'
require_relative 'build_context'
require_relative 'logger'
require_relative "default_standard_stream_log_processor"

def get_context
  logger = Logger.new(processor: default_standard_stream_log_processor)
  BuildContext.new(
    file_processing_history: FileProcessingHistory.new,
    logger: logger
  )
end