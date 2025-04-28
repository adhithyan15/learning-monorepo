require 'minitest/autorun'
require_relative '../lib/build_context'
require_relative '../lib/file_processing_history'

class BuildContextTest < Minitest::Test
  def setup
    @context = BuildContext.new(file_processing_history: FileProcessingHistory.new)
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
end