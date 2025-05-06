require 'minitest/autorun'
require_relative '../lib/build_context'
require_relative '../lib/file_processing_history'
require_relative '../lib/logger'
require_relative '../lib/exit_handler'
require_relative '../lib/env_accessor'
require_relative '../lib/command_runner'
require_relative '../lib/path_resolver'
require_relative "memory_processor"

class BuildContextTest < Minitest::Test
  def setup
    processor = MemoryProcessor.new
    logger = Logger.new(processor: processor)
    file_processing_history = FileProcessingHistory.new
    exit_handler = ExitHandler.new
    env = EnvAccessor.new
    command_runner = CommandRunner.new(logger)
    path_resolver = PathResolver.new

    @context = BuildContext.new(
      file_processing_history: file_processing_history,
      logger: logger,
      exit_handler: exit_handler,
      env: env,
      command_runner: command_runner,
      path_resolver: path_resolver
    )
  end

  def test_file_processing_history_exists
    assert_instance_of FileProcessingHistory, @context.file_processing_history
  end

  def test_file_processing_history_behavior
    path = 'some/build/file'
    refute @context.file_processing_history.already_processed?(path)
    @context.file_processing_history.mark_processed(path)
    assert @context.file_processing_history.already_processed?(path)
  end

  def test_logger_exists
    assert_instance_of Logger, @context.logger
  end
end
