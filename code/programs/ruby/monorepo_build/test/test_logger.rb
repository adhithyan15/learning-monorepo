require "minitest/autorun"
require_relative "../lib/logger"

# Memory processor to capture logs during tests
class MemoryProcessor
  attr_reader :logs

  def initialize
    @logs = []
  end

  def process(level:, message:)
    @logs << { level: level, message: message }
  end
end

class LoggerTest < Minitest::Test
  def setup
    @memory = MemoryProcessor.new
    @logger = Logger.new(processor: @memory)
  end

  def test_info_logs_message
    @logger.info("Build started")

    assert_equal [{ level: :info, message: "Build started" }], @memory.logs
  end

  def test_warn_logs_message
    @logger.warn("Low disk space")

    assert_equal [{ level: :warn, message: "Low disk space" }], @memory.logs
  end

  def test_error_logs_message
    @logger.error("Build failed")

    assert_equal [{ level: :error, message: "Build failed" }], @memory.logs
  end

  def test_fatal_logs_message
    @logger.fatal("Critical error!")

    assert_equal [{ level: :fatal, message: "Critical error!" }], @memory.logs
  end

  def test_debug_logs_message
    @logger.debug("Variable x = 42")

    assert_equal [{ level: :debug, message: "Variable x = 42" }], @memory.logs
  end
end
