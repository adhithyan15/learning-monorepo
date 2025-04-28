require 'minitest/autorun'
require_relative '../lib/build_context'
require_relative '../lib/file_processing_history'
require_relative '../lib/logger'
require_relative "memory_processor"

class BuildContextTest < Minitest::Test
  def setup
    processor = MemoryProcessor.new
    logger = Logger.new(processor: processor)
    @context = BuildContext.new(
      file_processing_history: FileProcessingHistory.new,
      logger: logger
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
