# lib/get_context.rb
require_relative 'file_processing_history'
require_relative 'default_standard_stream_log_processor'
require_relative 'logger'
require_relative 'exit_handler'
require_relative 'build_context'
require_relative 'env_accessor'
require_relative 'command_runner'
require_relative 'path_resolver'

def get_context(
  logger_to_override: nil,
  exit_handler_to_override: nil,
  command_runner_to_override: nil,
  env_accessor_to_override: nil,
  path_resolver_to_override: nil,
  file_processing_history_to_override: nil
)
  logger = if logger_to_override
             logger_to_override
           else
             log_processor = default_standard_stream_log_processor
             Logger.new(processor: log_processor)
           end

  exit_handler = exit_handler_to_override || ExitHandler.new
  command_runner = command_runner_to_override || CommandRunner.new(logger: logger)
  env_accessor = env_accessor_to_override || EnvAccessor.new
  path_resolver = path_resolver_to_override || PathResolver.new
  file_processing_history = file_processing_history_to_override || FileProcessingHistory.new

  BuildContext.new(
    file_processing_history: file_processing_history,
    logger: logger,
    exit_handler: exit_handler,
    command_runner: command_runner,
    env: env_accessor,
    path_resolver: path_resolver
  )
end