# lib/get_context.rb
require_relative 'file_processing_history'
require_relative 'default_standard_stream_log_processor'
require_relative 'logger'
require_relative 'exit_handler'
require_relative 'build_context'
require_relative 'env_accessor'
require_relative 'command_runner'

def get_context
  log_processor = default_standard_stream_log_processor
  logger = Logger.new(processor: log_processor)
  file_processing_history = FileProcessingHistory.new
  exit_handler = ExitHandler.new
  env = EnvAccessor.new
  command_runner = CommandRunner.new(logger)

  BuildContext.new(
    file_processing_history: file_processing_history,
    logger: logger,
    exit_handler: exit_handler,
    env: env,
    command_runner: command_runner
  )
end