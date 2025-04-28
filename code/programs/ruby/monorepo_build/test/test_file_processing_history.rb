require 'minitest/autorun'
require_relative '../lib/file_processing_history'

class FileProcessingHistoryTest < Minitest::Test
  def setup
    @history = FileProcessingHistory.new
  end

  def test_initially_not_processed
    refute @history.already_processed?('some/path')
  end

  def test_mark_and_check_processed
    @history.mark_processed('some/path')
    assert @history.already_processed?('some/path')
  end

  def test_mark_multiple_paths
    @history.mark_processed('path/one')
    @history.mark_processed('path/two')
    assert @history.already_processed?('path/one')
    assert @history.already_processed?('path/two')
    refute @history.already_processed?('path/three')
  end
end
