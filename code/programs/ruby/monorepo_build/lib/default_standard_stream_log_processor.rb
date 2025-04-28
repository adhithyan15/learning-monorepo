require_relative "standard_stream_log_processor"

def default_standard_stream_log_processor
  StandardStreamLogProcessor.new(
    ->(msg) { STDOUT.puts msg },
    ->(msg) { STDERR.puts msg }
  )
end