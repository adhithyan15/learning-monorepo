require 'minitest/autorun'
require_relative '../lib/logger'

class LoggerTest < Minitest::Test
  def setup
    @logger = Logger.new
  end

  def test_info_format
    expected_output = "[INFO] Hello, World\n"
    assert_output(expected_output) do
      @logger.info("Hello, World")
    end
  end

  def test_warn_format
    expected_output = "[WARN] Be careful\n"
    assert_output(expected_output) do
      @logger.warn("Be careful")
    end
  end

  def test_error_format
    expected_output = "[ERR] Something went wrong\n"
    assert_output(expected_output) do
      @logger.error("Something went wrong")
    end
  end

  def test_fatal_format
    expected_output = "[FATAL ERR] Critical error occurred\n"
    assert_output(expected_output) do
      @logger.fatal("Critical error occurred")
    end
  end

  def test_debug_format
    expected_output = "[DEBUG] Debugging info here\n"
    assert_output(expected_output) do
      @logger.debug("Debugging info here")
    end
  end
end
