# test/test_standard_stream_log_processor.rb
require "minitest/autorun"
require_relative "../lib/standard_stream_log_processor"

class TestStandardStreamLogProcessor < Minitest::Test
  def setup
    @stdout_messages = []
    @stderr_messages = []

    @processor = StandardStreamLogProcessor.new(
      ->(msg) { @stdout_messages << msg },
      ->(msg) { @stderr_messages << msg }
    )
  end

  def test_info_goes_to_stdout
    @processor.process(level: :info, message: "Build started")
    assert_equal ["[INFO] Build started"], @stdout_messages
    assert_empty @stderr_messages
  end

  def test_warn_goes_to_stdout
    @processor.process(level: :warn, message: "Low disk space")
    assert_equal ["[WARN] Low disk space"], @stdout_messages
    assert_empty @stderr_messages
  end

  def test_debug_goes_to_stdout
    @processor.process(level: :debug, message: "Variable x = 42")
    assert_equal ["[DEBUG] Variable x = 42"], @stdout_messages
    assert_empty @stderr_messages
  end

  def test_error_goes_to_stderr
    @processor.process(level: :error, message: "Build failed")
    assert_equal ["[ERROR] Build failed"], @stderr_messages
    assert_empty @stdout_messages
  end

  def test_fatal_goes_to_stderr
    @processor.process(level: :fatal, message: "Critical crash")
    assert_equal ["[FATAL] Critical crash"], @stderr_messages
    assert_empty @stdout_messages
  end

  def test_unknown_level_defaults_to_stdout
    @processor.process(level: :whatever, message: "Unknown level")
    assert_equal ["[WHATEVER] Unknown level"], @stdout_messages
    assert_empty @stderr_messages
  end
end
